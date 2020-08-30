using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class HairPreview : MonoBehaviour
{
    //private int Segaments = 7;

    //private void OnDrawGizmos()
    //{
    //    if (!DebugDraw || GetVertices() == null || !ValidateImpl(false))
    //        return;
    //    var scalpToWorld = ScalpProvider.ToWorldMatrix;
    //    var vertices = GetVertices();
    //    for (var i = 1; i < vertices.Count; i++)
    //    {
    //        if (i % Segaments == 0)
    //            continue;
    //        var vertex1 = scalpToWorld.MultiplyPoint3x4(vertices[i - 1]);
    //        var vertex2 = scalpToWorld.MultiplyPoint3x4(vertices[i]);
    //        Gizmos.DrawLine(vertex1, vertex2);
    //    }
    //    var worldBounds = GetBounds();
    //    Gizmos.DrawWireCube(worldBounds.center, worldBounds.size);
    //}
}
