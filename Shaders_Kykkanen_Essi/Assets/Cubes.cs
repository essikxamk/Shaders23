using System;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class Cubes : MonoBehaviour
{
    [SerializeField, Range(0f, 360f)] private float angle;
    [SerializeField, Range(0f, 40f)] private float frequency;
    [SerializeField] private ComputeShader cube_shader;
    [SerializeField] private Mesh cube_mesh;
    [SerializeField] private Material cube_material;
    private static readonly int direction = Shader.PropertyToID(("direction"));
    private static readonly int positions = Shader.PropertyToID(("positions"));
    private static readonly int current_time = Shader.PropertyToID(("time"));
    private static readonly int freq = Shader.PropertyToID(("frequency"));
    
    private static int SimulationKernel;

    private const int cube_amount = 128 * 128;

    private Vector4[] cube_positions = new Vector4[cube_amount];

    private Matrix4x4[] cube_matrices = new Matrix4x4[cube_amount];

    private ComputeBuffer cube_buffer;

    private AsyncGPUReadbackRequest GPURequest;
    
    private void PopulateCubes(Vector4[] positions)
    {
        for (uint x = 0; x < 128; ++x)
        {
            for (uint y = 0; y < 128; ++y)
            {
                uint idx = x * 128 + y;
                positions[idx] = new Vector4(x / 128f, 0, y / 128f);
            }
        }
    }

    private void DispatchCubes()
    {
        //suuntavektori alltojen liikkkeelle
        Vector2 dir = new Vector2(Mathf.Cos(Mathf.Deg2Rad * angle), Mathf.Sin(Mathf.Deg2Rad * angle));
        cube_shader.SetFloat(current_time, Time.time);
        cube_shader.SetFloat(freq, frequency);
        cube_shader.SetVector(direction, dir);
        
        cube_shader.Dispatch(SimulationKernel, 128/8, 128/8,1);
    }
    // Start is called before the first frame update
    void Start()
    {
        SimulationKernel = cube_shader.FindKernel("Simulate");
        cube_buffer = new ComputeBuffer(cube_amount, 4 * sizeof(float));
        PopulateCubes(cube_positions);
        cube_buffer.SetData(cube_positions);
        cube_shader.SetBuffer(SimulationKernel, positions, cube_buffer);
        DispatchCubes();
        GPURequest = AsyncGPUReadback.Request(cube_buffer);
    }

    // Update is called once per frame
    void Update()
    {
        if (GPURequest.done)
        {
            cube_positions = GPURequest.GetData<Vector4>().ToArray();
            for (int i = 0; i < cube_amount; ++i)
            {
                cube_matrices[i] = Matrix4x4.TRS((Vector3)cube_positions[i] + transform.position, Quaternion.identity, 
                    Vector3.one * (1 / 128f));
            }
            GPURequest = AsyncGPUReadback.Request(cube_buffer);
        }
        DispatchCubes();
        Graphics.DrawMeshInstanced(cube_mesh, 0, cube_material, cube_matrices);
    }

    private void OnDisable()
    {
        cube_buffer.Release();
    }

    private void OnDestroy()
    {
        cube_buffer.Release();
    }
}
