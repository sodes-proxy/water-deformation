using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class changeScenes : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {

    }
    public void rippleScene()
    {
        SceneManager.LoadScene("ripple", LoadSceneMode.Single);
    }
    public void waterScene()
    {
        SceneManager.LoadScene("water", LoadSceneMode.Single);
    }
}
