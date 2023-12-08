using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class GOL : MonoBehaviour
{
    [SerializeField] private ComputeShader GOLShader;
    [SerializeField] private Material GOLMaterial;
    [SerializeField] private Seeds seeds;
    [SerializeField] private Color color;
    [SerializeField] private float timeToUpdate;
    private float timeOfNextUpdate = 2;
    private bool stateOn=true;
    private RenderTexture GOLTexture1;
    private RenderTexture GOLTexture2;
    private static int Update1Kernel;
    private static int Update2Kernel;
    private static int FullTextureKernel;
    private static int RPentominoKernel;
    private static int AcornKernel;
    private static int GunKernel;
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int TextureState1 = Shader.PropertyToID("State1");
    private static readonly int TextureState2 = Shader.PropertyToID("State2");
    private static readonly int CellColor = Shader.PropertyToID("CellColour");
    enum Seeds
    {
        FullTexture,
        RPentomino,
        Acorn,
        Gun,
    }
    void Start()
    {
        Update1Kernel = GOLShader.FindKernel("Update1");       
        Update2Kernel = GOLShader.FindKernel("Update2");
        FullTextureKernel = GOLShader.FindKernel("InitFullTexture");
        RPentominoKernel = GOLShader.FindKernel("InitRPentomino");
        AcornKernel = GOLShader.FindKernel("InitAcorn");
        GunKernel = GOLShader.FindKernel("InitGun");

        GOLTexture1 = new RenderTexture(512, 512, 0, DefaultFormat.LDR)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point,  
        };

        GOLTexture2 = new RenderTexture(512, 512, 0, DefaultFormat.LDR)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point,
        };

        GOLTexture1.Create();
        GOLTexture2.Create();
        GOLMaterial.SetTexture(BaseMap, GOLTexture1);
        GOLShader.SetTexture(Update1Kernel, TextureState1, GOLTexture1);
        GOLShader.SetTexture(Update1Kernel, TextureState2, GOLTexture2);
        GOLShader.SetTexture(Update2Kernel, TextureState1, GOLTexture1);
        GOLShader.SetTexture(Update2Kernel, TextureState2, GOLTexture2);
        GOLShader.SetTexture(FullTextureKernel, TextureState1, GOLTexture1);
        GOLShader.SetTexture(RPentominoKernel, TextureState1, GOLTexture1);
        GOLShader.SetTexture(AcornKernel, TextureState1, GOLTexture1);
        GOLShader.SetTexture(GunKernel, TextureState1, GOLTexture1);

        GOLShader.SetVector(CellColor, color);

        switch (seeds)
        {
            case Seeds.FullTexture:
                GOLShader.Dispatch(FullTextureKernel, 512 / 8, 512 / 8, 1);
                break;
            case Seeds.RPentomino:
                GOLShader.Dispatch(RPentominoKernel, 512 / 8, 512 / 8, 1);
                break;
            case Seeds.Acorn:
                GOLShader.Dispatch(AcornKernel, 512 / 8, 512 / 8, 1);
                break;
            case Seeds.Gun:
                GOLShader.Dispatch(GunKernel, 512 / 8, 512 / 8, 1);
                break;
            default:
                break;
        }
    }


    void Update()
    {
        if(Time.time>=timeOfNextUpdate)
        {
            timeOfNextUpdate += timeToUpdate;
            if (stateOn)
            {
                GOLShader.Dispatch(Update1Kernel, 512 / 8, 512 / 8, 1);
                stateOn = false;
                GOLMaterial.SetTexture(BaseMap, GOLTexture2);
            }
            else
            {
                GOLShader.Dispatch(Update2Kernel, 512 / 8, 512 / 8, 1);
                stateOn = true;
                GOLMaterial.SetTexture(BaseMap, GOLTexture1);
            }
        }
    }

    private void OnDisable()
    {
        GOLTexture1.Release();
        GOLTexture2.Release();
    }

    private void OnDestroy()
    {
        GOLTexture1.Release();
        GOLTexture2.Release();
    }
}
