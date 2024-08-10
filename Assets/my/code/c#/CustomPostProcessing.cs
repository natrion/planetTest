using UnityEngine;
using System.Collections.Generic;
[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomPostProcessing : MonoBehaviour
{

    public static List<Material> planetsPostProcessingMaterial = new List<Material>() ;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        
        if (planetsPostProcessingMaterial.Count != 0) 
        {
            //Graphics.Blit(src, dest);
            Graphics.Blit( src,  dest, planetsPostProcessingMaterial[0]);
            /*
            RenderTexture passingTexture = new RenderTexture(src.width, src.height, src.depth);
            RenderTexture passingTexture2 = new RenderTexture(src.width, src.height, src.depth);

            Graphics.Blit(src, passingTexture);
            //Graphics.Blit(src, dest, postProcessingMaterial);
            bool changeWhatPassingTexture = false;
            foreach (Material planetMaterial in planetsPostProcessingMaterial)
            {
                if (changeWhatPassingTexture == false)
                {
                    Graphics.Blit(passingTexture, passingTexture2, planetMaterial);
                }
                else
                {
                    Graphics.Blit(passingTexture2, passingTexture, planetMaterial);
                }
                changeWhatPassingTexture = !changeWhatPassingTexture;
            }
            if (changeWhatPassingTexture == false)
            {
                Graphics.Blit(passingTexture, dest);
            }
            else
            {
                Graphics.Blit(passingTexture2, dest);
            }*/
        }
        else
        {
            Graphics.Blit(src, dest);
        }
        
    }
    public RenderTexture depthTexture ;
    private void Start()
    {
        gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
        
        gameObject.GetComponent<Camera>().targetTexture = depthTexture;

    }
    private void Update()
    {


        foreach (Material material in changeDapthTextureMaterials)
        {
            material.SetTexture("_DepthTex", depthTexture);
        }
        

        for (int i = 0; i < planetsPostProcessingMaterial.Count; i++)
        {           
            if (planetsPostProcessingMaterial[i] == null)
            {
                planetsPostProcessingMaterial.RemoveAt(i);
                i--;
            }
        }
    }

    public static List<Material> changeDapthTextureMaterials = new List<Material>();

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
