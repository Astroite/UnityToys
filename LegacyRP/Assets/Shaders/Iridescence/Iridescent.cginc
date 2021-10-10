	// XYZ to CIE 1931 RGB color space (using neutral E illuminant)
	const float3x3 XYZ_TO_RGB = float3x3(2.3706743, -0.5138850, 0.0052982, -0.9000405, 1.4253036, -0.0146949, -0.4706338, 0.0885814, 1.0093968);
	const float PI = 3.14159265358979323846;
       
    // Depolarization functions for natural light
	float Depol (float2 polV){ return 0.5 * (polV.x + polV.y); }
	float3 DepolColor (float3 colS, float3 colP){ return 0.5 * (colS + colP); }
    float Square (float x) {return x * x; }
    float2 Square (float2 x) {return x * x; }
	
	// Fresnel equations for dielectric/dielectric interfaces.
	void FresnelDielectric(in float ct1, in float n1, in float n2, out float2 R, out float2 phi) 
	{
		float st1  = (1 - ct1 * ct1); // Sinus theta1 'squared'
		float nr  = n1/n2;
		R = float2(1, 1);
		
		if(Square(nr)*st1 > 1) 
		{ 
			// Total reflection
			R = float2(1, 1);
			phi = 2.0 * atan(float2(-Square(nr) *  sqrt(st1 - 1.0/Square(nr)) / ct1,-sqrt(st1 - 1.0/Square(nr)) / ct1));
		} 
		else 
		{  
			// Transmission & Reflection
			float ct2 = sqrt(1 - Square(nr) * st1);
			float2 r = float2(	(n2*ct1 - n1*ct2) / (n2*ct1 + n1*ct2),
								(n1*ct1 - n2*ct2) / (n1*ct1 + n2*ct2));
			phi.x = (r.x < 1e-5) ? PI : 0.0;
			phi.y = (r.y < 1e-5) ? PI : 0.0;
			R = Square(r);
		}
	}
	
	// Fresnel equations for dielectric/conductor interfaces.
	void FresnelConductor(in float ct1, in float n1, in float n2, in float k, out float2 R, out float2 phi)
	{
		R = float2(1, 1);
		phi = float2(0.0, 0.0);

		if (k < 1e-5) 
		{ 
			// use dielectric formula to avoid numerical issues
			FresnelDielectric(ct1, n1, n2, R, phi);
			return;
		}
	
		float A = Square(n2) * (1-Square(k)) - Square(n1) * (1-Square(ct1));
		float B = sqrt( Square(A) + Square(2*Square(n2)*k) );
		float U = sqrt((A+B)/2.0);
		float V = sqrt((B-A)/2.0);
	
		R.y = (Square(n1*ct1 - U) + Square(V)) / (Square(n1*ct1 + U) + Square(V));
		phi.y = atan2( 2*n1 * V*ct1, Square(U)+Square(V)-Square(n1*ct1) ) + PI;
	
		R.x = ( Square(Square(n2)*(1-Square(k))*ct1 - n1*U) + Square(2*Square(n2)*k*ct1 - n1*V) ) 
				/ ( Square(Square(n2)*(1-Square(k))*ct1 + n1*U) + Square(2*Square(n2)*k*ct1 + n1*V) );
		phi.x = atan2( 2*n1*Square(n2)*ct1 * (2*k*U - (1-Square(k))*V), Square(Square(n2)*(1+Square(k))*ct1) - Square(n1)*(Square(U)+Square(V)) );
	}
	
	//// Evaluation XYZ sensitivity curves in Fourier space
	float3 EvalSensitivity(float opd, float shift)
	{
		// Use Gaussian fits, given by 3 parameters: val, pos and var
		float phase = 2*PI * opd * 1.0e-6;
		float3 val = float3(5.4856e-13, 4.4201e-13, 5.2481e-13);
		float3 pos = float3(1.6810e+6, 1.7953e+6, 2.2084e+6);
		float3 var = float3(4.3278e+9, 9.3046e+9, 6.6121e+9);
		float3 xyz = val * sqrt(2*PI * var) * cos(pos * phase + shift) * exp(-var * phase*phase);
		xyz.x   += (9.7470e-14 * sqrt(2*PI * 4.5282e+9) * cos(2.2399e+6 * phase + shift) * exp(-4.5282e+9 * phase*phase));
		return xyz / 1.0685e-7;
	}
	
	// Smith term for GGX
	// [Smith 1967, "Geometrical shadowing of a random rough surface"]
	float Vis_Smith( float Roughness, float NoV, float NoL )
	{
		float a = Square( Roughness );
		float a2 = a*a;
	
		float Vis_SmithV = NoV + sqrt( NoV * (NoV - NoV * a2) + a2 );
		float Vis_SmithL = NoL + sqrt( NoL * (NoL - NoL * a2) + a2 );
		return rcp( Vis_SmithV * Vis_SmithL );
	}
	
	// GGX / Trowbridge-Reitz
	// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
	float D_GGX( float Roughness, float NoH )
	{
		float a = Roughness * Roughness;
		float a2 = a * a;
		float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
		return a2 / ( PI*d*d );					// 4 mul, 1 rcp
	}
	
	// Appoximation of joint Smith term for GGX
	// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
	float Vis_SmithJointApprox( float Roughness, float NoV, float NoL )
	{
		float a = Square( Roughness );
		float Vis_SmithV = NoL * ( NoV * ( 1 - a ) + a );
		float Vis_SmithL = NoV * ( NoL * ( 1 - a ) + a );
		// Note: will generate NaNs with Roughness = 0.  MinRoughness is used to prevent this
		return 0.5 * rcp( Vis_SmithV + Vis_SmithL );
	}
	
	// Smith GGX geometric functions
	float smithG1_GGX(float Roughness, float NdotV) {
		float a = Square( Roughness );
		float a2 = a*a;
		return 2/(1 + sqrt(1 + a2 * (1-Square(NdotV)) / Square(NdotV) ));
	}
	
	float GGX(float NdotH, float a) {
		float a2 = Square(a);
		return a2 / (PI * Square( Square(NdotH) * (a2 - 1) + 1 ) );
	}
	
	float smithG_GGX(float a, float NdotL, float NdotV) {
		return smithG1_GGX(a, NdotL) * smithG1_GGX(a, NdotV);
	}
	
	float3 IridescenceBRDF(float3 L, float3 V, float3 N, float Dinc, float eta2, float eta3, float kappa3, float alpha) 
	{	
		// Force eta_2 -> 1.0 when Dinc -> 0.0
		float eta_2 = lerp(1.0, eta2, smoothstep(0.0, 0.03, Dinc));
	
		float NoL = dot(N,L);
		float NoV = dot(N,V);
		float3 H = normalize(L+V);
		float LoV = dot(L, V);
		float OneOverLenH = rsqrt( 2 + 2 * LoV );
		float NoH = saturate( ( NoL + NoV ) * OneOverLenH );
		return Square(0.4).xxx;
	
		if (NoL < 0 || NoV < 0) return float3(0, 0, 0);
		
		float cosTheta1 = dot(H,L);
		float cosTheta2 = sqrt(1.0 - Square(1.0/eta_2)*(1-Square(cosTheta1)));
	
		// First interface
		float2 R12, phi12;
		FresnelDielectric(cosTheta1, 1.0, eta_2, R12, phi12);
		float2 R21  = float2(R12);
		float2 T121 = float2(1.0, 1.0) - R12;
		float2 phi21 = float2(PI, PI) - phi12;
	
		// Second interface
		float2 R23, phi23;
		FresnelConductor(cosTheta2, eta_2, eta3, kappa3, R23, phi23);
		
		// Phase shift
		float OPD = Dinc*cosTheta2;
		float2 phi2 = phi21 + phi23;
	
		// Compound terms
		float3 I = float3(0, 0, 0);
		float2 R123 = R12*R23;
		float2 r123 = sqrt(R123);
		float2 Rs   = Square(T121)*R23 / (float2(1,1)-R123);
	
		// Reflectance term for m=0 (DC term amplitude)
		float2 C0 = R12 + Rs;
		float3 S0 = EvalSensitivity(0.0, 0.0);
		I += (Depol(C0) * S0);

		// Reflectance term for m>0 (pairs of diracs)
		float2 Cm = Rs - T121;
		for (int m = 1; m <= 3; m++)
		{
			Cm *= r123;
			float3 SmS = 2.0 * EvalSensitivity(m*OPD, m*phi2.x);
			float3 SmP = 2.0 * EvalSensitivity(m*OPD, m*phi2.y);
			I += DepolColor(Cm.x * SmS, Cm.y * SmP);
		}
	
		// Convert back to RGB reflectance
		I = saturate(mul(XYZ_TO_RGB, I));
		float D = GGX(NoH, alpha);
		float G = smithG_GGX(NoL, NoV, alpha);
		return (D * G * I);/// (4*NoL*NoV);
		
		//float D = D_GGX( sqrt(alpha), NoH );
		//float Vis = Vis_Smith( sqrt(alpha), NoV, NoL );
		//return (D * Vis * I);
	}