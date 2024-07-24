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
    [SerializeField] private PlanetData onePlanetData;
    public static List<Planet> planets = new List<Planet>();
    public static Material planeMaterial;
    public static ComputeShader computeShader;

   // public static ComputeShader grassComputeShader;
   // public static Material grassMaterial;
   // public static Mesh grassMesh;

   // [SerializeField]private  ComputeShader grassComputeShaderNonStatic;
   // [SerializeField] private  Material grassMaterialNonStatic;
   // [SerializeField] private  Mesh grassMeshNonStatic;

    public static GameObject player;

    [SerializeField] private Material planeMaterialNostatic;
    [SerializeField] private ComputeShader computeShaderNostatic;
    [SerializeField] private GameObject playerNostatic;

    private static int[] indicesFront;
    private static int[] indicesBack;
    [SerializeField] private int vertextSideCountNostatic;
    public static int vertextSideCount;

  //  [SerializeField] private int grassSideCountNonStatic;
  //  public static int grassSideCount;

    void Start()
    {     
        StartImporantvariables();

        new Planet(onePlanetData);
    }
    
    public void StartImporantvariables()
    {
       // grassIterations = grassIterationsNonStatic;
        teststatic = test;
        // GrassDis = GrassDisNonStatic;
        // grassComputeShader = grassComputeShaderNonStatic;
        // grassMaterial = grassMaterialNonStatic;
        //  grassMesh = grassMeshNonStatic;

        grassMaterial = grassMaterialNonStatic;
        
        MinChunkSize = MinChunkSizeNonStatic;
        player = playerNostatic;
        computeShader = computeShaderNostatic;
        planeMaterial = planeMaterialNostatic;
        vertextSideCount = vertextSideCountNostatic;
        vertextSideCount = Mathf.CeilToInt((float)vertextSideCount / 16) * 16;

        chunkGeneratingDistance = chunkGeneratingDistanceNostatic;

        chunkInChunkSideNum = chunkInChunkSideNostatic;

       // grassSideCountNonStatic =  Mathf.CeilToInt((float)grassSideCountNonStatic / 4) * 4;
       // grassSideCount = grassSideCountNonStatic;

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

    public class GPUinstanceData
    {
        public Vector4[] colors;
        public Matrix4x4[] matrixes;
        public Mesh mesh;
        public Material material;
    }
    //private static List<Chunk> chunksWithGPUinstancedata = new List<Chunk>();

    // private static List<GPUinstanceData> grasstoDraw = new List<GPUinstanceData>();
    [SerializeField] private Material grassMaterialNonStatic;
    public static Material grassMaterial;

    [SerializeField] GameObject test;
    public static GameObject teststatic;

   // public static int grassIterations = 4;

    //[SerializeField]public int grassIterationsNonStatic = 4;

    [System.Serializable]
    public class Chunk {

        //public List<GPUinstanceData> chunkGPUinstanceData = new List<GPUinstanceData>();

        public GPUinstanceData[,] GrassGPUinstanceData;

        public GameObject chunk;
        public GameObject GrassChunk;

        public Vector2 chunkPos;
        public float chunkSize;
        public int chunkSide;
        public Vector3 chunkWorldPos;
        public Chunk[,] chunksInsade;

        public void activateChunk()
        {
            chunk.SetActive(true);

           // if (chunkGPUinstanceData.Count != 0)
           // {
           //     chunksWithGPUinstancedata.Add(this);

           // }
            //drawData();
        }

        public void DeactivateChunk()
        {
            chunk.SetActive(false);

           // if (chunkGPUinstanceData.Count != 0)
          //  {
           //     chunksWithGPUinstancedata.Remove(this);
           // }
        }

        /*
        public async void drawData()
        {
            doDrawData = true;
            while (doDrawData == true)
            {
                for (int i = 0; i < chunkGPUinstanceData.Count ; i++)
                {
                    Graphics.DrawMeshInstanced(chunkGPUinstanceData[i].mesh, 0, chunkGPUinstanceData[i].material, chunkGPUinstanceData[i].matrixes);
                }
                await Task.Delay(4);
            }
        }
        */
        
        public async Task loadChunks(PlanetData planet)
        {
            float chunkPlayerDistance = Vector3.Distance(chunkWorldPos, player.transform.position);

            float PlayerPlanetHight = Vector3.Distance(player.transform.position, planet.planetGameObject.transform.position);

           
            float newchunkSize = chunkSize / (float)chunkInChunkSideNum;
       
            Vector2 newchunks2Dpositions = chunkPos - (chunkSize / 2) * Vector2.one + (newchunkSize / 2) * Vector2.one;

            float ChunkSpawnDistance = (planet.planetR*2 / Mathf.Pow(2, CalculateExponent(newchunkSize, (float)chunkInChunkSideNum*0.6f, planet.planetR * 2) )) * chunkGeneratingDistance;

            //float ChunkSpawnDistance = newchunkSize * chunkGeneratingDistance * 2;

            if (newchunkSize < MinChunkSize )
            {
                /*
                if (chunkPlayerDistance < MinChunkSize * 2)
                {
                    if (this.GrassGPUinstanceData == null)
                    {
                        this.GrassGPUinstanceData = new GPUinstanceData[grassIterations, grassIterations];
                    }
                    

                    for (int x = 0; x < grassIterations; x++)
                    {
                        for (int y = 0; y < grassIterations; y++)
                        {
                            
                            int mul = vertextSideCount / grassIterations;
                            Vector2Int indexPos = new Vector2Int(x * mul + mul / 2, y * mul+ mul / 2);

                            Vector3[] vertices = this.chunk.GetComponent<MeshFilter>().mesh.vertices;

                            Vector3 pos = vertices[indexPos.x* vertextSideCount + indexPos.y];

                            if (Vector3.Distance(player.transform.position, pos) < GrassDis)
                            {                                                            
                                if (this.GrassGPUinstanceData[x, y] ==null)
                                {
                                    float grassSideChunkSize = (float)chunkSize / (float)grassIterations;
                                    Vector2 grassChunkPos = chunkPos - ((Vector2.one * chunkSize) / 2) + ((Vector2)indexPos/(float)vertextSideCount) * chunkSize;
                                    this.GrassGPUinstanceData[x, y] = generateGrassGPUinstanceData(grassChunkPos, grassSideChunkSize, chunkSide, planet);
                                    grasstoDraw.Add(this.GrassGPUinstanceData[x, y]);
                                }
                                else if(grasstoDraw.Contains(this.GrassGPUinstanceData[x, y]) == false)
                                {
                                    grasstoDraw.Add(this.GrassGPUinstanceData[x, y]);
                                }
                                //Graphics.DrawMeshInstanced(data.mesh, 0 ,data.material, data.matrixes);
                            }
                            

                        }
                    }
                }*/
                return;

            }

            if (chunksInsade == null)
            {
                chunksInsade = new Chunk[chunkInChunkSideNum, chunkInChunkSideNum];
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
                           
                            GameObject newChunkGameObject;

                            if (newchunkSize / chunkInChunkSideNum < MinChunkSize* chunkInChunkSideNum)
                            {
                                newChunkGameObject = await GeneratePlane(newchunk2Dposition, newchunkSize, chunkSide, planet, true,true);

                                if (newchunkSize / chunkInChunkSideNum < MinChunkSize )
                                {
                                    newChunkGameObject.AddComponent<MeshCollider>();
                                }
                            }
                            else
                            {
                                newChunkGameObject = await GeneratePlane(newchunk2Dposition, newchunkSize, chunkSide, planet, false,false);
                            }

                            newchunk.chunk = newChunkGameObject;
                            newchunk.chunkWorldPos = newChunkGameObject.GetComponent<MeshFilter>().mesh.vertices[(vertextSideCount * vertextSideCount) / 2 + vertextSideCount / 2];

                         
                            chunksInsade[x, y] = newchunk;

                            newchunk.loadChunks(planet);
                            newchunk.activateChunk();
                        }
                        else
                        {
                            chunksInsade[x, y].activateChunk();
                            chunksInsade[x, y].loadChunks(planet);
                        }                    
                    }
                }
                DeactivateChunk();
            }
            else
            {
                for (int x = 0; x < chunkInChunkSideNum; x++)
                {
                    for (int y = 0; y < chunkInChunkSideNum; y++)
                    {
                        if (chunksInsade[x, y] != null)
                        {
                            chunksInsade[x, y].DeactivateChunk();
                        }
                    }
                }
                activateChunk();
            }

            if (CalculateDistance(planet.planetR, PlayerPlanetHight, planet.planetGameObject) * 1.5f < chunkPlayerDistance)
            {
                if (chunksInsade != null)
                {
                    for (int x = 0; x < chunkInChunkSideNum; x++)
                    {
                        for (int y = 0; y < chunkInChunkSideNum; y++)
                        {
                            if (chunksInsade[x, y] != null)
                            {
                                chunksInsade[x, y].DeactivateChunk();
                            }
                        }
                    }
                }
                DeactivateChunk();
            }
        }
    }
    /*
    private void Update()
    {
        drawAllThings();
    }
    public Vector3 GetPosition(Matrix4x4 m)
    {
        return new Vector3(m[0, 3], m[1, 3], m[2, 3]);
    }

    private async Task drawAllThings()
    {
        // foreach (Chunk chunk in chunksWithGPUinstancedata)
        //  {
        //     for (int i = 0; i < chunk.chunkGPUinstanceData.Count; i++)
        //     {
        //         Graphics.DrawMeshInstanced(chunk.chunkGPUinstanceData[i].mesh, 0, chunk.chunkGPUinstanceData[i].material, chunk.chunkGPUinstanceData[i].matrixes);
        //     }
        // }
        foreach (GPUinstanceData grass in grasstoDraw)
        {
            if (Vector3.Distance( GetPosition(grass.matrixes[(grassIterations / 2) * grassIterations + grassIterations / 2]),player.transform.position )> GrassDis)
            {
                grasstoDraw.Remove(grass);
            }
            else
            {
                Graphics.DrawMeshInstanced(grass.mesh, 0, grass.material, grass.matrixes, grass.matrixes.Length, new MaterialPropertyBlock(), UnityEngine.Rendering.ShadowCastingMode.Off, false);
                
            }
        }
    }*/
    //public static float GrassDis;
    //[SerializeField]private float GrassDisNonStatic;
    public static float CalculateDistance(float r, float h , GameObject Planet)
    {
       //float totalVelocity = player.GetComponent<Rigidbody>().velocity.magnitude + player.GetComponent<Rigidbody>().angularVelocity.magnitude;

        if (h <= r *0.8f)
        {
            player.transform.position = (player.transform.position - Planet.transform.position).normalized * r * 3;

            player.GetComponent<Rigidbody>().velocity = Vector3.zero;
            player.GetComponent<Rigidbody>().angularVelocity = Vector3.zero;
            return 0 ;
        }
        // Ensure the height is greater than the radius for the tangent to exist     
        else
        {
            // Calculate the distance using the Pythagorean theorem
            float distance = (float)Math.Sqrt(h * h - r * r);
            return distance;
        }           
    }

    public static float chunkGeneratingDistance;

    public static int chunkInChunkSideNum;

    [SerializeField] private float chunkGeneratingDistanceNostatic;

    [SerializeField] private int chunkInChunkSideNostatic;

    public struct objectInfo
    {
        public Vector3 pos;
        public Vector4 rot;
        public int type;
        public int done;
    };
    [System.Serializable]
    public struct TypeInfo
    {
        public int type;
        public int whatBiome;
        public float rarity;
        public int OnSide1JustUp0;
        public float plusYpos;
    };

    [System.Serializable]
    public struct PlanetData{

        public TypeInfo[] PlanetTypeInfo;
        public GameObject[] PlanetTypeInfoObjects;
        public float AtmosphericDrag ;
        public float planetR;
        public float frequency;
        public int iterations;
        public float iterationSize;
        public float power;
        public float Intensity;
        public GameObject planetGameObject;

        public float OceanFreqency ;
        public int OceanIterations ;
        public float OceanIterationSize ;
        public float OceanPower;
        public float OceanIntensity ;

        public float valleyHight; 
        public float valleyDistortion; 
        public float valleyPower;

        public float _BiomTransotionNum;
        public float _BiomNoiseFrequency;
        public float _BiomNoiseIterations;
        public float _BiomNoiseIterationSize;
        public float _BiomNoisePower;
        public float _BiomNoiseIntensity;
    }

    [System.Serializable]
    public class Planet 
    {     
        public PlanetData planetData;
        public List<Chunk> chunks;
        public Planet(PlanetData planetData)
        {
            CreatePlanet(planetData);
        }
        public async Task CreatePlanet(PlanetData planetData)
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
                
                GameObject newChunkGameObject = await GeneratePlane(newchunk2Dposition, newchunkSize, chunkSide, this.planetData,false,false);

                newchunk.chunkWorldPos = newChunkGameObject.GetComponent<MeshFilter>().mesh.vertices[(vertextSideCount * vertextSideCount) /2+ vertextSideCount/2];
               
                newchunk.chunk = newChunkGameObject;

                this.chunks.Add(newchunk);
            }
            planets.Add(this);
            LoadChunks();
        }
        public async Task LoadChunks()
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
    public static bool isMaking = false; 
    static async Task<GameObject> GeneratePlane(Vector2 posOnSphere, float planeLength, int whatSide,PlanetData planetdata ,bool CreateGrass , bool CreateObjects)
    {
        isMaking = true;
        while (isMaking == false)
        {
            await Task.Delay(10);
        }

        

        int vertextTotalCount = vertextSideCount * vertextSideCount;

        int kernelHandle = computeShader.FindKernel("VertexGive");

        // Create compute buffers
        ComputeBuffer posComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 3);
        ComputeBuffer norComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 3);
        ComputeBuffer uvComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 2);

        int typeInfoSize = System.Runtime.InteropServices.Marshal.SizeOf(typeof(TypeInfo));
        // Create a buffer to hold the TypeInfo array
        ComputeBuffer typeInfoBuffer = new ComputeBuffer(planetdata.PlanetTypeInfo.Length, typeInfoSize);
        typeInfoBuffer.SetData(planetdata.PlanetTypeInfo);

        int objectInfoSize = System.Runtime.InteropServices.Marshal.SizeOf(typeof(objectInfo));
        // Create a buffer to hold the TypeInfo array
        ComputeBuffer objectInfoBuffer = new ComputeBuffer(vertextTotalCount * 2, objectInfoSize, ComputeBufferType.Append);

        // Bind the buffer to the compute shader

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

        computeShader.SetFloat("OceanFreqency", planetdata.OceanFreqency);
        computeShader.SetInt("OceanIterations", planetdata.OceanIterations);
        computeShader.SetFloat("OceanIterationSize", planetdata.OceanIterationSize);
        computeShader.SetFloat("OceanPower", planetdata.OceanPower);
        computeShader.SetFloat("OceanIntensity", planetdata.OceanIntensity);

        computeShader.SetFloat("valleyDistortion", planetdata.valleyDistortion);
        computeShader.SetFloat("valleyHight", planetdata.valleyHight);
        computeShader.SetFloat("valleyPower", planetdata.valleyPower);

        computeShader.SetFloat("_BiomNoiseFrequency", planetdata._BiomNoiseFrequency );
        computeShader.SetFloat("_BiomNoiseIntensity", planetdata._BiomNoiseIntensity);
        computeShader.SetFloat("_BiomNoiseIterations", planetdata._BiomNoiseIterations);
        computeShader.SetFloat("_BiomNoiseIterationSize", planetdata._BiomNoiseIterationSize);
        computeShader.SetFloat("_BiomNoisePower", planetdata._BiomNoisePower);
        computeShader.SetFloat("_BiomTransotionNum", planetdata._BiomTransotionNum);

        computeShader.SetBuffer(kernelHandle, "positions", posComputeBuffer);
        computeShader.SetBuffer(kernelHandle, "normals", norComputeBuffer);
        computeShader.SetBuffer(kernelHandle, "UVs", uvComputeBuffer);

        computeShader.SetBuffer(kernelHandle, "typeInfos", typeInfoBuffer);

        computeShader.SetBuffer(kernelHandle, "resultObjects", objectInfoBuffer);
        computeShader.SetBool("canCreateObjects", CreateObjects);
        // Clear the append buffer
        objectInfoBuffer.SetCounterValue(0);

        // Dispatch compute shader
        computeShader.Dispatch(kernelHandle, vertextSideCount / 16, vertextSideCount / 16, 1);

        // Retrieve data from compute buffers
        Vector3[] positions = new Vector3[vertextTotalCount];
        Vector3[] normals = new Vector3[vertextTotalCount];
        Vector2[] uvs = new Vector2[vertextTotalCount];
        objectInfo[] objectInf = new objectInfo[vertextTotalCount*2];

        posComputeBuffer.GetData(positions);
        norComputeBuffer.GetData(normals);
        uvComputeBuffer.GetData(uvs);
        objectInfoBuffer.GetData(objectInf);

        // Release compute buffers
        posComputeBuffer.Release();
        norComputeBuffer.Release();
        uvComputeBuffer.Release();
        objectInfoBuffer.Release();

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

        if (CreateGrass == true)
        {
            GameObject grassPlane = Instantiate(plane);

            grassPlane.GetComponent<MeshRenderer>().material = grassMaterial;
            grassPlane.transform.parent = plane.transform;
        }

        if (CreateObjects == true)
        {
            GameObject ObjectParent = new GameObject("object parent");
            ObjectParent.transform.parent = plane.transform;

            bool isDone = false;
            int i = 0;
            while (isDone == false)
            {
              
                if (objectInf[i].done == 1 & objectInf.Length - 1 > i)
                {
                    //if (objectInf[i].type == 200)
                    //{
                        GameObject newGameobject = Instantiate(planetdata.PlanetTypeInfoObjects[objectInf[i].type]);
                        newGameobject.transform.position = objectInf[i].pos;
                        newGameobject.transform.rotation = new Quaternion(objectInf[i].rot.x, objectInf[i].rot.y, objectInf[i].rot.z, objectInf[i].rot.w);
                        newGameobject.transform.parent = ObjectParent.transform;
                   //}
                }
                else
                {
                    isDone = true;
                }
                i++;
            }
            //print("lenght" + i);
        }


        isMaking = false;

        return plane;
    }

    /*
    static GPUinstanceData generateGrassGPUinstanceData(Vector2 posOnSphere, float planeLength, int whatSide, PlanetData planetdata)
    {
        
        int vertextTotalCount = vertextSideCount * vertextSideCount;

        int kernelHandle = computeShader.FindKernel("VertexGive");

        // Create compute buffers
        ComputeBuffer matrixesComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) *16);

        ComputeBuffer colorsComputeBuffer = new ComputeBuffer(vertextTotalCount, sizeof(float) * 4);

        // Set new plane parameters
        grassComputeShader.SetFloat("gridSize", vertextSideCount);
        grassComputeShader.SetFloat("whatSide", whatSide);
        grassComputeShader.SetFloat("planeLength", planeLength);
        grassComputeShader.SetVector("posOnSphere", new Vector4(posOnSphere.x, posOnSphere.y, 0, 0));

        // Set new planet parameters
        grassComputeShader.SetFloat("planetR", planetdata.planetR);
        grassComputeShader.SetFloat("freqency", planetdata.frequency);
        grassComputeShader.SetInt("iterations", planetdata.iterations);
        grassComputeShader.SetFloat("iterationSize", planetdata.iterationSize);
        grassComputeShader.SetFloat("power", planetdata.power);
        grassComputeShader.SetFloat("Intensity", planetdata.Intensity);
        grassComputeShader.SetFloat("OceanNoiseIntensity", planetdata.OceanNoiseIntensity);

        grassComputeShader.SetBuffer(kernelHandle, "matrixData", matrixesComputeBuffer);
        grassComputeShader.SetBuffer(kernelHandle, "ColorData", colorsComputeBuffer);

        // Dispatch compute shader
        grassComputeShader.Dispatch(kernelHandle, vertextSideCount / 4, vertextSideCount / 4, 1);

        // Retrieve data from compute buffers
        Matrix4x4[] matrixes = new Matrix4x4[vertextTotalCount];

        Vector4[] colors = new Vector4[vertextTotalCount];

        matrixesComputeBuffer.GetData(matrixes);
        colorsComputeBuffer.GetData(colors);
        // Release compute buffers
        matrixesComputeBuffer.Release();
        colorsComputeBuffer.Release();

        GPUinstanceData data = new GPUinstanceData();
        data.matrixes = matrixes;
        data.mesh = grassMesh;
        data.material = grassMaterial;
        data.colors = colors;
        return data;
    }   */
}
