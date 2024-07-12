using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class RayDirectionEffect : MonoBehaviour
{
    public Material postProcessingMaterial;
    public float planetR;
    public Vector3 planetPos;
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (postProcessingMaterial != null)
        {
            // Pass camera matrices to the shader
            Camera cam = GetComponent<Camera>();
            Matrix4x4 inverseProjectionMatrix = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false).inverse;
            Matrix4x4 viewMatrix = cam.worldToCameraMatrix.inverse;

            postProcessingMaterial.SetMatrix("_InverseProjectionMatrix", inverseProjectionMatrix);
            postProcessingMaterial.SetMatrix("_ViewMatrix", viewMatrix);
            postProcessingMaterial.SetVector("_PlanetPos", planetPos);
            postProcessingMaterial.SetFloat("_planetRadius", planetR);

            Graphics.Blit(source, destination, postProcessingMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}