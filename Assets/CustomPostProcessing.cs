using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomPostProcessing : MonoBehaviour
{
    public Material postProcessingMaterial;
    public Vector3 _PlanetPos;
    public float _PlanetRadius;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (postProcessingMaterial != null)
        {
            postProcessingMaterial.SetFloat("_PlanetRadius", _PlanetRadius);
            postProcessingMaterial.SetVector("_PlanetPos", _PlanetPos);

            Graphics.Blit(src, dest, postProcessingMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
