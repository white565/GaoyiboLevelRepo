using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : MonoBehaviour
{
    public bool isOpen = false; // Indicates whether the door is open or closed
    public float speed; // Speed at which the door opens/closes
    public float stopHeight; // Height at which the door stops when opening

    void Update()
    {
        if(!isOpen)
        {
            // Logic for when the door is closed
            return;
        }
        else
        {
            transform.position -= new Vector3(0, 0.1f, 0) * speed * Time.deltaTime; // Move the door downwards when open
        }

        if(transform.position.y <= stopHeight)
        {
            isOpen = false; // Close the door when it reaches a certain position
        }
    }
}
