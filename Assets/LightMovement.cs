using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightMovement : MonoBehaviour {
    public float delta = 30f;
    public float speed = 1f;

    private Vector3 _startPos;

    // Use this for initialization
    void Start () {
        _startPos = transform.position;
	}
	
	// Update is called once per frame
	void Update () {

        Vector3 v = _startPos;
        v.x += delta * Mathf.Sin(Time.time/2 * speed)*3;
        transform.position = v;

    }
}
