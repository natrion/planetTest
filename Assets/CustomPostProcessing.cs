using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class CustomPostProcessing : MonoBehaviour
{
    public Material postProcessingMaterial;
    public Vector3 _PlanetPos;
    public float waterRadius;
    public float mul;
    public float exp;
    public float oceanBottom;
    public Gradient oceanHightColor;
    public Texture2D test;
    public float frequency;
    public int iterations;
    public float iterationSize;
    public float power;
    public float Intensity;
    public float waveStreanght;
    public float atmosphereSize;
    public float atmosphereDensity;
    public Color atmosphereColor;
    public float atmosphericFallof;

    public float cloudsStepSize;
    public float cloudsFreqency = 1.0f;
    public int cloudsIterations = 5;
    public float cloudsIterationSize = 2.0f;
    public float cloudsPower = 2.0f;
    public float cloudsIntensity = 2.0f;

    public float cloudsTopFreqency = 1.0f;
    public int cloudsTopIterations = 5;
    public float cloudsTopIterationSize = 2.0f;
    public float cloudsTopPower = 2.0f;
    public float cloudsHight = 2.0f;

    public Color cloudColor;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        
        if (postProcessingMaterial != null) 
        {
            Color lightColor = RenderSettings.sun.color;
            postProcessingMaterial.SetVector("_sunDir", RenderSettings.sun.transform.forward);
            postProcessingMaterial.SetVector("_sunColor", new Vector4(lightColor.r, lightColor.g, lightColor.b, lightColor.a));
            postProcessingMaterial.SetFloat("_sunIntensity", RenderSettings.sun.intensity);

            postProcessingMaterial.SetFloat("_WaterRadius", waterRadius);
            postProcessingMaterial.SetVector("_PlanetPos", _PlanetPos);
            postProcessingMaterial.SetFloat("_mul", mul);
            postProcessingMaterial.SetFloat("_exp", exp);
            postProcessingMaterial.SetFloat("_oceanBottom", oceanBottom);
            test = GradientToTexture2D(oceanHightColor, 1000, 1);
            postProcessingMaterial.SetTexture("_oceanColor", test);

            
            postProcessingMaterial.SetFloat("freqency", frequency);
            postProcessingMaterial.SetInt("iterations", iterations);
            postProcessingMaterial.SetFloat("iterationSize", iterationSize);
            postProcessingMaterial.SetFloat("power", power);
            postProcessingMaterial.SetFloat("Intensity", Intensity); 
            postProcessingMaterial.SetFloat("_waveStreanght", waveStreanght);
            postProcessingMaterial.SetFloat("_atmosphereSize", atmosphereSize);
            postProcessingMaterial.SetFloat("_atmosphereDensity", atmosphereDensity);

            postProcessingMaterial.SetFloat("_cloudsStepSize", cloudsStepSize);
            postProcessingMaterial.SetFloat("_cloudsFreqency", cloudsFreqency);
            postProcessingMaterial.SetFloat("_cloudsIterations", cloudsIterations);
            postProcessingMaterial.SetFloat("_cloudsIterationSize", cloudsIterationSize);
            postProcessingMaterial.SetFloat("_cloudsPower", cloudsPower);
            postProcessingMaterial.SetFloat("_cloudsIntensity", cloudsIntensity);

            postProcessingMaterial.SetFloat("_cloudsTopFreqency", cloudsTopFreqency);
            postProcessingMaterial.SetFloat("_cloudsTopIterations", cloudsTopIterations);
            postProcessingMaterial.SetFloat("_cloudsTopIterationSize", cloudsTopIterationSize);
            postProcessingMaterial.SetFloat("_cloudsTopPower", cloudsTopPower);
            postProcessingMaterial.SetFloat("_cloudsHight", cloudsHight);

            postProcessingMaterial.SetVector("_cloudColor", new Vector4(cloudColor.r, cloudColor.g, cloudColor.b, cloudColor.a));

            postProcessingMaterial.SetFloat("_atmosphericFallof", atmosphericFallof);

            postProcessingMaterial.SetVector("_atmosphereColor", new Vector4(atmosphereColor.r, atmosphereColor.g, atmosphereColor.b, atmosphereColor.a) );
            Graphics.Blit(src, dest, postProcessingMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
        
    }
    private void Start()
    {
        
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
