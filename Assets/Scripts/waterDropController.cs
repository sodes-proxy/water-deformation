using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class waterDropController : MonoBehaviour
{
    public Material waterRipple;
    // Start is called before the first frame update
    void Start()
    {
        waterRipple.SetFloat("_DropFell", 0f);

    }
    void Update()
    {
    }
    private void OnCollisionEnter(Collision other)
    {
        //makes the ripple at the point the drop collided with the surface
        float distanceX = this.transform.position.x - other.gameObject.transform.position.x;
        float distanceZ = this.transform.position.z - other.gameObject.transform.position.z;
        waterRipple.SetFloat("_DropFell", 1f);
        waterRipple.SetVector("_DropPosition", new Vector3(distanceX, 0, distanceZ));
        Destroy(this.gameObject);
    }
}
