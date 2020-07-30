using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ProbeController : MonoBehaviour
{

    public ReflectionProbe probe;
    public Transform mirrorPlaneTransform;

    void Start()
    {
        this.probe = GetComponent<ReflectionProbe>();
    }

    void Update()
    {
        var diffY = mirrorPlaneTransform.position.y - Camera.main.transform.position.y;

        this.probe.transform.position = new Vector3(
            Camera.main.transform.position.x,
            mirrorPlaneTransform.position.y + diffY,
            Camera.main.transform.position.z
        );
    }
}