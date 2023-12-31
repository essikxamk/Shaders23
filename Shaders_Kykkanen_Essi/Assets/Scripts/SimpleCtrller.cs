using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SimpleCtrller : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] private Material ProxMaterial;
    private static int PlayerPosID = Shader.PropertyToID("_PlayerPosition");
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.A))
            movement += Vector3.left;

        if (Input.GetKey(KeyCode.W))
            movement += Vector3.forward;

        if (Input.GetKey(KeyCode.D))
            movement += Vector3.right;

        if (Input.GetKey(KeyCode.S))
            movement += Vector3.back;

        transform.Translate(Time.deltaTime * 5 * movement.normalized, Space.World);
        ProxMaterial.SetVector(PlayerPosID, transform.position);
    }
}
