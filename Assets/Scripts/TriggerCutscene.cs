using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerCutscene : MonoBehaviour
{
    public GameObject mainCam;
    public GameObject cutsceneCam;
    public float duration = 3f;


    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            StartCoroutine(PlayCutscene());
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
