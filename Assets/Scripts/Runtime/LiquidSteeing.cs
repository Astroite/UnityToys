using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LiquidSteeing : MonoBehaviour
{
    [Range(-0.2f, 0.2f)]
    public float shakeSpeed = 0.1f;

    private Renderer m_renderer;
    private Vector4 m_planeNormal;
    private Vector3 RotatePos;

    private void OnEnable()
    {
        m_renderer = this.GetComponent<Renderer>();
    }

    private void OnDisable()
    {
        m_renderer = null;
    }

    private void Start()
    {
        m_planeNormal = new Vector4(0, 1, 0, 0);
        RotatePos = this.transform.position + new Vector3(0, 0.5f, 0);
        m_renderer.sharedMaterial.SetVector("_Centre", this.transform.position + new Vector3(0, 0.5f, 0));
    }

    private void FixedUpdate()
    {
        m_planeNormal.x += shakeSpeed;
        float cosx = Vector3.Dot(Vector3.Normalize(m_planeNormal), Vector3.up);
        float sinx = Mathf.Sqrt(1 - cosx * cosx);
        float flag = m_planeNormal.x > 0 ? -1 : 1; 
        this.transform.position = RotatePos + new Vector3(0.5f * sinx * flag, -0.5f * cosx, 0);
        this.transform.rotation = Quaternion.Euler(0, 0, 90.0f * sinx * flag);
         
        if (Mathf.Abs(m_planeNormal.x) > 1) shakeSpeed = -shakeSpeed;
        //Debug.Log(m_planeNormal.x);
    }

    // Update is called once per frame
    void Update()
    {
        m_renderer.sharedMaterial.SetVector("_PlaneNormal", m_planeNormal);
    }
}