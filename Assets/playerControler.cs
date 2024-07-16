using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerControler : MonoBehaviour
{
    public float GroundMoveForce = 10f;
    public float SpaceMoveForce = 10f;
    public float sensitivity = 5.0f; // Sensitivity of mouse movement
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked; // Lock cursor to center of screen
        Cursor.visible = false; // Hide cursor
    }
    public float planetRotationCangeDistance = 2;
    float YRotation;
    private PlanetGenerator.Planet curentPlanet;
    void Update()
    {
        controlPlayer();
    }

    void controlPlayer()
    {
        bool isonPlanet = false;


        foreach (PlanetGenerator.Planet planet in PlanetGenerator.planets)
        {
            if (Vector3.Distance(transform.position, planet.planetData.planetGameObject.transform.position) < planet.planetData.planetR * planetRotationCangeDistance)
            {
                isonPlanet = true;
                curentPlanet = planet;
            }
        }

        float Force = 0;

        if (isonPlanet == false)
        {
            Force = SpaceMoveForce;
            float mouseX = Input.GetAxis("Mouse X") * sensitivity;
            float mouseY = Input.GetAxis("Mouse Y") * sensitivity;

            // Rotate the object locally based on mouse movements
            transform.Rotate(Vector3.back*-1, mouseX, Space.Self); // Rotate around the object's Y-axis
            transform.Rotate(Vector3.left, mouseY, Space.Self); // Rotate around the object's X-axis
        }
        else
        {
            Force = GroundMoveForce;
            Vector3 planetPos = curentPlanet.planetData.planetGameObject.transform.position;

            Vector3 direction = (planetPos - transform.position).normalized;

            transform.rotation = Quaternion.FromToRotation(-transform.up, direction) * transform.rotation;

            float mY = Input.GetAxis("Mouse Y");
            float mX = Input.GetAxis("Mouse X");


            //transform.LookAt(curentPlanet.planetData.planetGameObject.transform);

            transform.Rotate((Vector3.up * mX) * sensitivity);

            YRotation += mY * sensitivity;
            YRotation = Mathf.Clamp(YRotation, -80, 80);
            transform.GetChild(0).localEulerAngles = Vector3.left * YRotation;

            transform.gameObject.GetComponent<Rigidbody>().drag = curentPlanet.planetData.AtmosphericDrag;
            transform.gameObject.GetComponent<Rigidbody>().angularDrag = curentPlanet.planetData.AtmosphericDrag;
        }

        float up = 0;
        if (Input.GetKey(KeyCode.Space))
        {
            up += 1;
        }
        if (Input.GetKey(KeyCode.LeftShift))
        {
            up -= 1;
        }

        Vector3 movement = new Vector3(Input.GetAxis("Vertical"), up , Input.GetAxis("Horizontal"));

        if (movement.x != 0 | movement.y != 0 | movement.z != 0)
        {
            // Calculate the direction to move based on the object's forward vector
            Vector3 moveDirectionForward = transform.GetChild(0).forward;
            Vector3 moveDirectionUp = transform.GetChild(0).up;
            Vector3 moveDirectionRight = transform.GetChild(0).right;

            Vector3 final = moveDirectionForward* movement.x + moveDirectionUp* movement.y + moveDirectionRight*movement.z;

            // Apply force in the direction the object is facing
            gameObject.GetComponent<Rigidbody>().AddForce(final * Force, ForceMode.Force);
        }
    }

    private void FixedUpdate()
    {
        if (PlanetGenerator.planets.Count != 0)
        {
            foreach (PlanetGenerator.Planet planet in PlanetGenerator.planets)
            {
                Vector3 planetPos = planet.planetData.planetGameObject.transform.position;

                float distance = Vector3.Distance(transform.position, planetPos);

                float planetMass = Mathf.Pow(planet.planetData.planetR, 3) * Mathf.PI * (4/3);
                float totalMul = (planetMass / (distance* distance) ) * gravityIntensity;

                Vector3 dir = planetPos - transform.position;

                gameObject.GetComponent<Rigidbody>().AddForce(dir * totalMul, ForceMode.Force);
            }
        }    
    }
    public float gravityIntensity = 1;
}
