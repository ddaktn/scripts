using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NumberWizard : MonoBehaviour {

	// Use this for initialization
	void Start () {
        int max = 1000;
        int min = 1;
        Debug.Log("Welcome to number wizard!");
        Debug.Log("Please pick a number...");
        Debug.Log("High number is: " + max);
        Debug.Log("Low number is: " + min);
        Debug.Log("Tell me if your number is higher or lower than my 500");
        Debug.Log("Push Up = Higher, Push Down = Lower, Push Enter = Correct");
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown(KeyCode.UpArrow))
        {
            Debug.Log("Up Arrow key was pressed.");
        }
        else if (Input.GetKeyDown(KeyCode.DownArrow))
        {
            Debug.Log("Down Arrow key was pressed.");
        }
        else if (Input.GetKeyDown(KeyCode.Return))
        {
            Debug.Log("You hit Enter.");
        }
        //else
        //{
        //    debug.log("please hit the up arrow, down arrow, or enter...");
        //}
	}
}
