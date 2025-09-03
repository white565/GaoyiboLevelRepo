using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Elevator : MonoBehaviour
{
    public Transform ground;
    public ElevatorTrigger trigger;
    public Transform start;
    public Transform end;
    public float speed;

    // Update is called once per frame
    void Update()
    {
        if (trigger.isUp)
        {
            if (Vector3.Distance(end.position, ground.position) > 0.1f)
            {
                ground.position += Vector3.up * Time.deltaTime * speed;
            }
        }
        else
        {
            if(Vector3.Distance(start.position, ground.position) > 0.1f)
            {
                ground.position -= Vector3.up * Time.deltaTime * speed;
            }
        }
    }
}
