using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using System.Threading.Tasks;
public class PlanetGenerator : MonoBehaviour
{
    [SerializeField] private float MinChunkSizeNonStatic;
    private static float MinChunkSize;
    [SerializeField] private  GameObject cubeNonStat;
    [SerializeField] private PlanetData onePlanetData;
    [SerializeField] private Planet planet;
    public static Material planeMaterial;
    public static ComputeShader computeShader;
    public static GameObject player;

    [SerializeField] private Material planeMaterialNostatic;
    [SerializeField] private ComputeShader computeShaderNostatic;
    [SerializeField] private GameObject playerNostatic;

    private static int[] indicesFront;
    private static int[] indicesBack;
    [SerializeField] private int vertextSideCountNostatic;
    public static int vertextSideCount;

 

    void Start()
    {
        
        StartImporantvariables();

        planet = new Planet(onePlanetData);
        //StartCoroutine(repeat());
    }
    private IEnumerator repeat()
    {
        bool Do = true;
        while (Do == true)
        {
            if (indicesFront != null)
            {
                foreach (Chunk item in planet.chunks)
                {
                    Destroy(item.chunk);
                }
                planet = new Planet(onePlanetData);
            }
            yield return new WaitForSecondsRealtime(0.5f);
        }
        
    }
    public void StartImporantvariables()
    {
        MinChunkSize = MinChunkSizeNonStatic;
        player = playerNostatic;
        computeShader = computeShaderNostatic;
        planeMaterial = planeMaterialNostatic;
        vertextSideCount = vertextSideCountNostatic;

        chunkGeneratingDistance = chunkGeneratingDistanceNostatic;

        chunkInChunkSideNum = chunkInChunkSideNostatic;

        vertextSideCount = Mathf.CeilToInt((float)vertextSideCount / 16) * 16;
        GenerateIndices();
    }
    void GenerateIndices()
    {
        indicesFront = new int[(vertextSideCount - 1) * (vertextSideCount - 1) * 6];
        int index = 0;
        for (int y = 0; y < vertextSideCount - 1; y++)
        {
            for (int x = 0; x < vertextSideCount - 1; x++)
            {
                int topLeft = y * vertextSideCount + x;
                int bottomLeft = (y + 1) * vertextSideCount + x;

                indicesFront[index++] = topLeft + 1;
                indicesFront[index++] = bottomLeft;
                indicesFront[index++] = topLeft;

                indicesFront[index++] = topLeft + 1;
                indicesFront[index++] = bottomLeft + 1;
                indicesFront[index++] = bottomLeft;
            }
        }

        indicesBack = new int[(vertextSideCount - 1) * (vertextSideCount - 1) * 6];
        index = 0;
        for (int y = 0; y < vertextSideCount - 1; y++)
        {
            for (int x = 0; x < vertextSideCount - 1; x++)
            {
                int topLeft = y * vertextSideCount + x;
                int bottomLeft = (y + 1) * vertextSideCount + x;

                               
                indicesBack[index++] = topLeft;
                indicesBack[index++] = bottomLeft;
                indicesBack[index++] = topLeft + 1;

                indicesBack[index++] = bottomLeft;
                indicesBack[index++] = bottomLeft + 1;
                indicesBack[index++] = topLeft + 1;
            }
        }

    }
    public static float DivideNTimesUsingLog(float dividend, float divisor, int times)
    {
        // Calculate the logarithm of the divisor
        float logBase = (float)Math.Log(divisor);

        // Use the logarithm to simulate repeated division
        float result = dividend / (float)Math.Pow(Math.E, logBase * times);

        return result;
    }
    public static float CalculateExponent(float baseNumber, float multiplier, float targetNumber)
    {       
        // Calculate the logarithm of targetNumber to the base multiplier
        float logBase = (float)Math.Log(targetNumber / baseNumber, multiplier);

        // Return the logarithm result
        return logBase;        
    }
    [System.Serializable]
    public class Chunk {
        public GameObject chunk;
        public Vector2 chunkPos;
        public float chunkSize;
        public int chunkSide;
        public Vector3 chunkWorldPos;
        public Chunk[,] chunksInsade;

        public void loadChunks(PlanetData planet)
        {
            float chunkPlayerDistance = Vector3.Distance(chunkWorldPos, player.transform.position);

            float PlayerPlanetHight = Vector3.Distance(player.transform.position, planet.planetGameObject.transform.position);

            if (CalculateDistance(planet.planetR, PlayerPlanetHight)*1.5f < chunkPlayerDistance)
            {
                if (chunksInsade != null)
                {
                    for (int x = 0; x < chunkInChunkSideNum; x++)
                    {
                        for (int y = 0; y < chunkInChunkSideNum; y++)
                        {
                            if (chunksInsade[x, y] != null)
                            {
                                chunksInsade[x, y].chunk.SetActive(false);
                            }
                        }
                    }
                }              
                chunk.SetActive(false);
                return;
            }
            float newchunkSize = chunkSize / (float)chunkInChunkSideNum;
       
            Vector2 newchunks2Dpositions = chunkPos - (chunkSize / 2) * Vector2.one + (newchunkSize / 2) * Vector2.one;
         

            float ChunkSpawnDistance = newchunkSize * chunkGeneratingDistance;

            if (chunksInsade == null)
            {
                chunksInsade = new Chunk[chunkInChunkSideNum, chunkInChunkSideNum];
            }

            if (newchunkSize < MinChunkSize)
            {
                return;
            }

            if (ChunkSpawnDistance > chunkPlayerDistance)
            {
                for (int x = 0; x < chunkInChunkSideNum; x++)
                {
                    for (int y = 0; y < chunkInChunkSideNum; y++)
                    {
                        if (chunksInsade[x, y] == null)
                        {
                            Chunk newchunk = new Chunk();

                            Vector2 newchunk2Dposition = newchunks2Dpositions + new Vector2(x , y) * (newchunkSize- newchunkSize/vertextSideCount);

                            newchunk.chunkPos = newchunk2Dposition;
                            newchunk.chunkSide = chunkSide;
                            newchunk.chunkSize = newchunkSize;
                           
                            GameObject newChunkGameObject = GeneratePlane(newchunk2Dposition, newchunkSize, chunkSide, planet);

                            if (newchunkSize / chunkInChunkSideNum < MinChunkSize)
                            {
                                newChunkGameObject.AddComponent<MeshCollider>();
                            }

                            newchunk.chunk = newChunkGameObject;
                            newchunk.chunkWorldPos = newChunkGameObject.GetComponent<MeshFilter>().mesh.vertices[(vertextSideCount * vertextSideCount) / 2 + vertextSideCount / 2];

                         
                            chunksInsade[x, y] = newchunk;

                            newchunk.loadChunks(planet);
                        }
                        else
                        {
                            chunksInsade[x, y].chunk.SetActive(true);
                            chunksInsade[x, y].loadChunks(planet);
                        }                    
                    }
                }
                chunk.SetActive(false);
            }
            else
            {
                for (int x = 0; x < chunkInChunkSideNum; x++)
                {
                    for (int y = 0; y < chunkInChunkSideNum; y++)
                    {
                        if (chunksInsade[x, y] != null)
                        {
                            chunksInsade[x, y].chunk.SetActive(false);
                        }
                    }
                }
                chunk.SetActive(true);
            }
            
        }
    }
    public static float CalculateDistance(float r, float h)
    {
        // Ensure the height is greater than the radius for the tangent to exist
        if (h <= r)
        {
            throw new ArgumentException("Height must be greater than the radius for a tangent line to exist.");
        }

        // Calculate the distance using the Pythagorean theorem
        float distance = (float)Math.Sqrt(h * h - r * r);
        return distance;
    }

    public static float chunkGeneratingDistance;

    public static int chunkInChunkSideNum;

    [SerializeField] private float chunkGeneratingDistanceNostatic;

    [SerializeField] private int chunkInChunkSideNostatic;

    [System.Serializable]
    public struct PlanetData{
        public float planetR;
        public float frequency;
        public int iterations;
        public float iterationSize;
        public float power;
        public float Intensity;
        public GameObject planetGameObject;
        public float OceanNoiseIntensity;
    }

    [System.Serializable]
    public class Planet
    {     
        public PlanetData planetData;
        public List<Chunk> chunks;
        public Planet(PlanetData planetData)
        {
            this.planetData = planetData;

            this.planetData.planetGameObject = new GameObject("planet");

            this.chunks = new List<Chunk>();
            for (int chunkSide = 1; chunkSide < 7; chunkSide++)
            {
                Chunk newchunk = new Chunk();
                Vector2 newchunk2Dposition = Vector2.zero;
                float newchunkSize = planetData.planetR * 2f;
                newchunk.chunkPos = newchunk2Dposition;
                newchunk.chunkSide = chunkSide;
                newchunk.chunkSize = newchunkSize;
                
                GameObject newChunkGameObject = GeneratePlane(newchunk2Dposition, newchunkSize, chunkSide, this.planetData);

                newchunk.chunkWorldPos = newChunkGameObject.GetComponent<MeshFilter>().mesh.vertices[(vertextSideCount * vertextSideCount) /2+ vertextSideCount/2];
               
                newchunk.chunk = newChunkGameObject;

                this.chunks.Add(newchunk);
            }
            LoadChunks();
        }
        public async void LoadChunks()
        {
            bool docCode = true;
            while (docCode == true)
            {
                foreach (Chunk chunk in chunks)
                {
                    chunk.loadChunks(this.planetData);
                }
                await Task.Delay(10);
            }
        }
    }
    static GameObject GeneratePlane(Vector2 posOnSphere, float planeLength, int whatSide,PlanetData planetdata)
    {
        int vertextTotalCount = vertextSideCount * vertextSideCount;

        int kernelHandle = computeShader.FindKernel("VertexGive");

        // Create compute buffers
        ComputeBuffer posComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 3);
        ComputeBuffer norComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 3);
        ComputeBuffer uvComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 2);

        // Set new plane parameters
        computeShader.SetFloat("gridSize", vertextSideCount);
        computeShader.SetFloat("whatSide", whatSide);
        computeShader.SetFloat("planeLength", planeLength);
        computeShader.SetVector("posOnSphere", new Vector4(posOnSphere.x, posOnSphere.y, 0, 0));

        // Set new planet parameters
        computeShader.SetFloat("planetR", planetdata.planetR);
        computeShader.SetFloat("freqency", planetdata.frequency);
        computeShader.SetInt("iterations", planetdata.iterations);
        computeShader.SetFloat("iterationSize", planetdata.iterationSize);
        computeShader.SetFloat("power", planetdata.power);
        computeShader.SetFloat("Intensity", planetdata.Intensity); 
        computeShader.SetFloat("OceanNoiseIntensity", planetdata.OceanNoiseIntensity);

        computeShader.SetBuffer(kernelHandle, "positions", posComputeBuffer);
        computeShader.SetBuffer(kernelHandle, "normals", norComputeBuffer);
        computeShader.SetBuffer(kernelHandle, "UVs", uvComputeBuffer);

        // Dispatch compute shader
        computeShader.Dispatch(kernelHandle, vertextSideCount / 16, vertextSideCount / 16, 1);

        // Retrieve data from compute buffers
        Vector3[] positions = new Vector3[vertextTotalCount];
        Vector3[] normals = new Vector3[vertextTotalCount];
        Vector2[] uvs = new Vector2[vertextTotalCount];

        posComputeBuffer.GetData(positions);
        norComputeBuffer.GetData(normals);
        uvComputeBuffer.GetData(uvs);

        // Release compute buffers
        posComputeBuffer.Release();
        norComputeBuffer.Release();
        uvComputeBuffer.Release();

        // Create mesh
        Mesh planeMesh = new Mesh
        {
            vertices = positions,
            normals = normals,
            uv = uvs
        };
        if (whatSide % 2 == 0)
        {
            planeMesh.triangles = indicesBack;
        }
        else
        {
            planeMesh.triangles = indicesFront;
        }
        // Create GameObject and assign mesh
        GameObject plane = new GameObject("plane");

        MeshRenderer planeMeshRenderer = plane.AddComponent<MeshRenderer>();
        planeMeshRenderer.material = planeMaterial;

        MeshFilter planeMeshFilter = plane.AddComponent<MeshFilter>();
        planeMeshFilter.mesh = planeMesh;

        plane.transform.parent = planetdata.planetGameObject.transform;

        return plane;
    }
}
