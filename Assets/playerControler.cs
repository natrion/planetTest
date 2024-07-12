using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class playerControler : MonoBehaviour
{   
    public float moveForce = 10f;
    public float sensitivity = 5.0f; // Sensitivity of mouse movement
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked; // Lock cursor to center of screen
        Cursor.visible = false; // Hide cursor
    }
    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X") * sensitivity;
        float mouseY = Input.GetAxis("Mouse Y") * sensitivity;

        // Rotate the object locally based on mouse movements
        transform.Rotate(Vector3.up, mouseX, Space.Self); // Rotate around the object's Y-axis
        transform.Rotate(Vector3.left, mouseY, Space.Self); // Rotate around the object's X-axis

        if (Input.GetKey(KeyCode.Space))
        {
            // Calculate the direction to move based on the object's forward vector
            Vector3 moveDirection = transform.forward;

            // Apply force in the direction the object is facing
            gameObject.GetComponent<Rigidbody>().AddForce(moveDirection * moveForce, ForceMode.Force);
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

                float totalMul = (gravityIntensity * planet.planetData.planetR) / distance;

                Vector3 dir = planetPos - transform.position;

                gameObject.GetComponent<Rigidbody>().AddForce(dir * totalMul, ForceMode.Force);
            }
        }    
    }
    public float gravityIntensity = 1;
}
