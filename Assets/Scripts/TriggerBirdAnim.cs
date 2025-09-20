using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerBirdAnim : MonoBehaviour
{
    public GameObject bird;
    public float duration = 3f;


    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            StartCoroutine(PlayCutscene());
        }
    }

    IEnumerator PlayCutscene()
    {

        bird.SetActive(true);
        // Wait for the duration of the cutscene
        yield return new WaitForSeconds(duration);
        // Switch back to main camera
        bird.SetActive(false);
        // Optionally, disable this trigger so the cutscene only plays once
        gameObject.SetActive(false);
    }
}
