using UnityEngine;
using UnityEditor;
using Google.Protobuf.WellKnownTypes;

public class CubeMapTool : EditorWindow
{
    private Cubemap m_CubeMap = null;
    private Camera m_RenderCamera = null;

    [MenuItem("Tools/Cube Map Generate")]
    public static void GenerateCubeMap()
    {
        GetWindow<CubeMapTool>();
    }

    private void OnGUI()
    {
        m_CubeMap = EditorGUILayout.ObjectField(m_CubeMap, typeof(Cubemap), false, GUILayout.Width(400)) as Cubemap;
        m_RenderCamera = EditorGUILayout.ObjectField(m_RenderCamera, typeof(Camera), true, GUILayout.Width(400))as Camera;
        if (GUILayout.Button("Render To Cube Map"))
        {
            m_RenderCamera.RenderToCubemap(m_CubeMap);
        }
    }
}