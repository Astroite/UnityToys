using UnityEngine;

[ExecuteInEditMode]
public class PlanarReflection : MonoBehaviour
{
    private Camera reflectionCamera = null;
    private RenderTexture reflectionRT = null;
    private static bool isReflectionCameraRendering = false;
    private Material reflectionMaterial = null;

    private void OnWillRenderObject()
    {
        if (isReflectionCameraRendering)
            return;

        isReflectionCameraRendering = true;

        if (reflectionCamera == null)
        {
            var go = new GameObject("Reflection Camera");
            reflectionCamera = go.AddComponent<Camera>();
            reflectionCamera.CopyFrom(Camera.current);
        }
        if (reflectionRT == null)
        {
            reflectionRT = RenderTexture.GetTemporary(1024, 1024, 24);
        }

        UpdateCamearaParams(Camera.current, reflectionCamera);
        reflectionCamera.targetTexture = reflectionRT;
        reflectionCamera.enabled = false;

        var reflectM = CaculateReflectMatrix();
        reflectionCamera.worldToCameraMatrix = Camera.current.worldToCameraMatrix * reflectM;


        var normal = transform.up;
        var d = -Vector3.Dot(normal, transform.position);
        var plane = new Vector4(normal.x, normal.y, normal.z, d);
        //用逆转置矩阵将平面从世界空间变换到反射相机空间
        var viewSpacePlane = reflectionCamera.worldToCameraMatrix.inverse.transpose * plane;
        var clipMatrix = reflectionCamera.CalculateObliqueMatrix(viewSpacePlane);
        reflectionCamera.projectionMatrix = clipMatrix;


        //需要将背面裁剪反过来，因为仅改变了顶点，没有改变法向量，绕序反向，裁剪会不对
        GL.invertCulling = true;
        reflectionCamera.Render();
        GL.invertCulling = false;

        if (reflectionMaterial == null)
        {
            var renderer = GetComponent<Renderer>();
            reflectionMaterial = renderer.sharedMaterial;
        }
        reflectionMaterial.SetTexture("_ReflectionTex", reflectionRT);

        isReflectionCameraRendering = false;
    }

    /// <summary>
    /// 根据上文平面定义，需要平面法向量和平面上任意点，此处使用transform.up为法向量，transform.position为平面上的点
    /// 即需要保证平面模型的原点在平面上，否则可以尝试增加offset偏移
    /// </summary>
    /// <returns></returns>
    private Matrix4x4 CaculateReflectMatrix()
    {
        var normal = transform.up;
        var d = -Vector3.Dot(normal, transform.position);
        var reflectM = new Matrix4x4
        {
            m00 = 1 - 2 * normal.x * normal.x,
            m01 = -2 * normal.x * normal.y,
            m02 = -2 * normal.x * normal.z,
            m03 = -2 * d * normal.x,

            m10 = -2 * normal.x * normal.y,
            m11 = 1 - 2 * normal.y * normal.y,
            m12 = -2 * normal.y * normal.z,
            m13 = -2 * d * normal.y,

            m20 = -2 * normal.x * normal.z,
            m21 = -2 * normal.y * normal.z,
            m22 = 1 - 2 * normal.z * normal.z,
            m23 = -2 * d * normal.z,

            m30 = 0,
            m31 = 0,
            m32 = 0,
            m33 = 1
        };
        return reflectM;
    }

    private Matrix4x4 CalculateObliqueMatrix(Vector4 plane, Camera camera)
    {
        var viewSpacePlane = camera.worldToCameraMatrix.inverse.transpose * plane;
        var projectionMatrix = camera.projectionMatrix;

        var clipSpaceFarPanelBoundPoint = new Vector4(Mathf.Sign(viewSpacePlane.x), Mathf.Sign(viewSpacePlane.y), 1, 1);
        var viewSpaceFarPanelBoundPoint = camera.projectionMatrix.inverse * clipSpaceFarPanelBoundPoint;

        var m4 = new Vector4(projectionMatrix.m30, projectionMatrix.m31, projectionMatrix.m32, projectionMatrix.m33);
        //u = 2 * (M4·E)/(E·P)，而M4·E == 1，化简得
        //var u = 2.0f * Vector4.Dot(m4, viewSpaceFarPanelBoundPoint) / Vector4.Dot(viewSpaceFarPanelBoundPoint, viewSpacePlane);
        var u = 2.0f / Vector4.Dot(viewSpaceFarPanelBoundPoint, viewSpacePlane);
        var newViewSpaceNearPlane = u * viewSpacePlane;

        //M3' = P - M4
        var m3 = newViewSpaceNearPlane - m4;

        projectionMatrix.m20 = m3.x;
        projectionMatrix.m21 = m3.y;
        projectionMatrix.m22 = m3.z;
        projectionMatrix.m23 = m3.w;

        return projectionMatrix;
    }


    /// <summary>
    /// 需要实时同步相机的参数，比如编辑器下滚动滚轮，Editor相机的远近裁剪面就会变化
    /// </summary>
    /// <param name="srcCamera"></param>
    /// <param name="destCamera"></param>
    private void UpdateCamearaParams(Camera srcCamera, Camera destCamera)
    {
        if (destCamera == null || srcCamera == null)
            return;

        destCamera.clearFlags = srcCamera.clearFlags;
        destCamera.backgroundColor = srcCamera.backgroundColor;
        destCamera.farClipPlane = srcCamera.farClipPlane;
        destCamera.nearClipPlane = srcCamera.nearClipPlane;
        destCamera.orthographic = srcCamera.orthographic;
        destCamera.fieldOfView = srcCamera.fieldOfView;
        destCamera.aspect = srcCamera.aspect;
        destCamera.orthographicSize = srcCamera.orthographicSize;
    }
}