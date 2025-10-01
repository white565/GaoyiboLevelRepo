using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorTriggerSpecial : MonoBehaviour
{
    bool canInteract = false;
    Door door;

    public GameObject mainCam;
    public GameObject cutsceneCam;
    public float duration = 3f;

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
                StartCoroutine(PlayCutscene());
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

    IEnumerator PlayCutscene()
    {
        // Switch to cutscene camera
        mainCam.SetActive(false);
        cutsceneCam.SetActive(true);
        // Wait for the duration of the cutscene
        yield return new WaitForSeconds(duration);
        // Switch back to main camera
        cutsceneCam.SetActive(false);
        mainCam.SetActive(true);
        // Optionally, disable this trigger so the cutscene only plays once
        gameObject.SetActive(false);
    }
}
