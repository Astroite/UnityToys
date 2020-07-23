using UnityEngine;
using UnityEditor;

public class GraphVisualizer : EditorWindow
{
    [MenuItem("Examples/FocusedWindow")]
    public static void Init()
    {
        GetWindow<GraphVisualizer>("GraphVisualizer");
    }

    void OnGUI()
    {
        GUILayout.Label(EditorWindow.focusedWindow.ToString());
    }
}