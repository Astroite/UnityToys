using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayMarch : MonoBehaviour
{
    public Material m_rayMarchMat;
	public Material m_rayMarchBlenderMat;

	[Range(0, 2)]
	public int downSampling;
	private Camera m_cam;
	private RenderTexture m_resultRT;
	private RenderTexture m_preResultRT;
	private Matrix4x4 m_preVP;


	public int lineCount = 100;
	public float radius = 3.0f;
	static Material lineMaterial;
	Matrix4x4 matrix;


	private void OnEnable()
    {
		m_cam = GetComponent<Camera>();
		m_cam.depthTextureMode = DepthTextureMode.Depth;
		m_resultRT = new RenderTexture(1920 >> downSampling, 1080>>downSampling, 24, RenderTextureFormat.ARGB32);
		m_preResultRT = new RenderTexture(1920 >> downSampling, 1080 >> downSampling, 24, RenderTextureFormat.ARGB32);
		if (m_rayMarchMat.shader.name != "UnityToy/RayMarch" || !m_rayMarchMat)
        {
            m_rayMarchMat = new Material(Shader.Find("UnityToy/RayMarch"));
			Debug.Log("Mat Shader Error");
		}

		if (m_rayMarchBlenderMat.shader.name != "UnityToy/RayMarchBlender" || !m_rayMarchBlenderMat)
		{
			m_rayMarchBlenderMat = new Material(Shader.Find("UnityToy/RayMarchBlender"));
			Debug.Log("Blender Shader Error");
		}
	}

	//private void OnRenderObject()
	//{
	//	CreateLineMaterial();

	//	Vector4 vector40 = new Vector4(1, 0, 0, 0);
	//	Vector4 vector41 = new Vector4(0, 1, 0, 0);
	//	Vector4 vector42 = new Vector4(0, 0, 1, 0);
	//	Vector4 vector43 = new Vector4(-0.5f, -0.5f, 0.5f, 1);
	//	Matrix4x4 matrix = new Matrix4x4();
	//	matrix.SetColumn(0, vector40);
	//	matrix.SetColumn(1, vector41);
	//	matrix.SetColumn(2, vector42);
	//	matrix.SetColumn(3, vector43);
	//	Matrix4x4 matrix4X4 = transform.localToWorldMatrix * matrix;

	//	lineMaterial.SetPass(0);
	//	GL.PushMatrix();
	//	GL.MultMatrix(matrix4X4);
	//	GL.Begin(GL.QUADS);

	//	GL.MultiTexCoord2(0, 0.0f, 0.0f);
	//	GL.Vertex3(0.0f, 0.0f, 0.0f);

	//	GL.MultiTexCoord2(0, 1.0f, 0.0f);
	//	GL.Vertex3(1.0f, 0.0f, 0.0f);

	//	GL.MultiTexCoord2(0, 1.0f, 1.0f);
	//	GL.Vertex3(1.0f, 1.0f, 0.0f);

	//	GL.MultiTexCoord2(0, 0.0f, 1.0f);
	//	GL.Vertex3(0.0f, 1.0f, 0.0f);
	//	GL.End();
	//	GL.PopMatrix();
	//}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{

		m_rayMarchMat.SetMatrix("_LastFrameVPMatrix", m_preVP);
		m_rayMarchMat.SetTexture("_LastFrameTex", m_preResultRT);
		m_rayMarchMat.SetVector("_CameraPos", transform.position);
		CustomBlit(null, m_resultRT, m_rayMarchMat);
		Graphics.CopyTexture(m_resultRT, m_preResultRT);
		//Graphics.Blit(m_reusltRT, destination);
		m_rayMarchBlenderMat.SetTexture("_CloudTex", m_resultRT);
		Graphics.Blit(source, destination, m_rayMarchBlenderMat);

		m_preVP = m_cam.projectionMatrix * m_cam.worldToCameraMatrix;
	}

	void CustomBlit(RenderTexture source, RenderTexture dest, Material mat)
	{
		float fovWHalf = m_cam.fieldOfView * 0.5f;

		Vector3 toRight = m_cam.transform.right * Mathf.Tan(fovWHalf * Mathf.Deg2Rad) * m_cam.aspect;
		Vector3 toTop = m_cam.transform.up * Mathf.Tan(fovWHalf * Mathf.Deg2Rad);

		Vector3 topLeft = (m_cam.transform.forward - toRight + toTop);
		Vector3 topRight = (m_cam.transform.forward + toRight + toTop);
		Vector3 bottomRight = (m_cam.transform.forward + toRight - toTop);
		Vector3 bottomLeft = (m_cam.transform.forward - toRight - toTop);

		RenderTexture.active = dest;

		GL.PushMatrix();
		GL.LoadOrtho();

		mat.SetPass(0);

		GL.Begin(GL.QUADS);

		GL.MultiTexCoord2(0, 0.0f, 0.0f);
		GL.MultiTexCoord(1, bottomLeft);
		GL.Vertex3(0.0f, 0.0f, 0.0f);

		GL.MultiTexCoord2(0, 1.0f, 0.0f);
		GL.MultiTexCoord(1, bottomRight);
		GL.Vertex3(1.0f, 0.0f, 0.0f);

		GL.MultiTexCoord2(0, 1.0f, 1.0f);
		GL.MultiTexCoord(1, topRight);
		GL.Vertex3(1.0f, 1.0f, 0.0f);

		GL.MultiTexCoord2(0, 0.0f, 1.0f);
		GL.MultiTexCoord(1, topLeft);
		GL.Vertex3(0.0f, 1.0f, 0.0f);

		GL.End();
		GL.PopMatrix();
	}

	static void CreateLineMaterial()
	{
		if (!lineMaterial)
		{
			// Unity has a built-in shader that is useful for drawing
			// simple colored things.
			Shader shader = Shader.Find("Hidden/Internal-Colored");
			lineMaterial = new Material(shader);
			lineMaterial.hideFlags = HideFlags.HideAndDontSave;
			// Turn on alpha blending
			lineMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
			lineMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
			// Turn backface culling off
			lineMaterial.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Off);
			// Turn off depth writes
			lineMaterial.SetInt("_ZWrite", 0);
		}
	}

	private Matrix4x4 CamFrustum(Camera cam)
	{
		Matrix4x4 frustum = Matrix4x4.identity;
		float fov = Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
		Vector3 goUp = Vector3.up * fov;
		Vector3 goRight = Vector3.right * fov * cam.aspect;

		Vector3 TL = (-Vector3.forward - goRight + goUp);
		Vector3 TR = (-Vector3.forward + goRight + goUp);
		Vector3 BR = (-Vector3.forward + goRight - goUp);
		Vector3 BL = (-Vector3.forward - goRight - goUp);

		frustum.SetRow(0, TL);
		frustum.SetRow(1, TR);
		frustum.SetRow(2, BR);
		frustum.SetRow(3, BL);
		return frustum;
	}
}
