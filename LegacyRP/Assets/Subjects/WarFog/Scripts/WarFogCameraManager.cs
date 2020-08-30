using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WarFogCameraManager : MonoBehaviour
{
    public static WarFogCameraManager instance;
    public RenderTexture WarFogRT;

    private Camera m_mainCamera;
    private Camera m_fogCamera;
    private int downSample = 2;

    private void Awake()
    {
        instance = this;
    }

    private void OnEnable()
    {

        if (!m_mainCamera)
            m_mainCamera = Camera.main;

        if(!m_fogCamera)
            m_fogCamera = GetComponent<Camera>();

        if (!WarFogRT)
        {
            WarFogRT = new RenderTexture(m_mainCamera.pixelWidth >> downSample, m_mainCamera.pixelHeight >> downSample, 24, RenderTextureFormat.RFloat);
            WarFogRT.Create();
        }
        m_fogCamera.targetTexture = WarFogRT;
    }

    private void Start()
    {

    }

    void Update()
    {
        m_fogCamera.transform.position = m_mainCamera.transform.position;
        m_fogCamera.transform.rotation = m_mainCamera.transform.rotation;
    }
}
