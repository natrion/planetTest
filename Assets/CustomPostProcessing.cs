using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomPostProcessing : MonoBehaviour
{
    public Material postProcessingMaterial;
    public Vector3 _PlanetPos;
    public float _PlanetRadius;
    public float mul;
    public float exp;
    public float oceanBottom;
    public Gradient oceanHightColor;
    public Texture2D test;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (postProcessingMaterial != null) 
        {
            postProcessingMaterial.SetFloat("_PlanetRadius", _PlanetRadius);
            postProcessingMaterial.SetVector("_PlanetPos", _PlanetPos);
            postProcessingMaterial.SetFloat("_mul", mul);
            postProcessingMaterial.SetFloat("_exp", exp); 
            postProcessingMaterial.SetFloat("_oceanBottom", oceanBottom);
            test = GradientToTexture2D(oceanHightColor, 1000, 1);
            postProcessingMaterial.SetTexture("_oceanColor", test);
            Graphics.Blit(src, dest, postProcessingMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
    public static Texture2D GradientToTexture2D(Gradient gradient, int width, int height)
    {
        // Create a new Texture2D with the specified width and height
        Texture2D texture = new Texture2D(width, height);

        // Loop through each pixel of the texture
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                // Calculate the normalized position (0 to 1) along the gradient
                float t = (float)x / (width - 1);

                // Get the color from the gradient at the specified position
                Color color = gradient.Evaluate(t);

                // Set the color of the current pixel
                texture.SetPixel(x, y, color);
            }
        }

        // Apply changes to the texture
        texture.Apply();

        return texture;
    }
}
