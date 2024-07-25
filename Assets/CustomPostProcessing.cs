using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomPostProcessing : MonoBehaviour
{
    public Material postProcessingMaterial;
    public Vector3 _PlanetPos;
    public float _PlanetRadius;
    public Color color;
    public float mul;
    public float exp;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (postProcessingMaterial != null) 
        {
            postProcessingMaterial.SetFloat("_PlanetRadius", _PlanetRadius);
            postProcessingMaterial.SetVector("_PlanetPos", _PlanetPos);
            postProcessingMaterial.SetVector("_color", new Vector4(color.r, color.g, color.b,1) );
            postProcessingMaterial.SetFloat("_mul", mul);
            postProcessingMaterial.SetFloat("_exp", exp);
            Graphics.Blit(src, dest, postProcessingMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
