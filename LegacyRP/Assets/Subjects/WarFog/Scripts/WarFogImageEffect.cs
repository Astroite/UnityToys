using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Assertions;

public class WarFogImageEffect : MonoBehaviour
{
    public Color FogColor = new Color(0.2f, 0.2f, 0.2f, 1.0f);
    private Material m_mat;

    private void OnEnable()
    {
        if (!m_mat)
            m_mat = new Material(Shader.Find("Astroite/WarFog/WarFogImageEffect"));
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        m_mat.SetTexture("_MainTex", source);
        m_mat.SetTexture("_FogTex", WarFogCameraManager.instance.WarFogRT);
        m_mat.SetColor("_FogColor", FogColor);
        Graphics.Blit(source, destination, m_mat);
    }
}
