using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorTrigger : MonoBehaviour
{
    bool canInteract = false;
    Door door;

    private void Start()
    {
        door = transform.parent.GetComponentInChildren<Door>();
    }
    void Update()
    {
        if(canInteract && Input.GetKeyDown(KeyCode.E))
        {
            if(door != null)
            {
                door.isOpen = true; // Open the door when the player interacts
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            canInteract = true;
            Debug.Log("Player in range to interact with the door.");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            canInteract = false;
            Debug.Log("Player in range to interact with the door.");
        }
    }
}
