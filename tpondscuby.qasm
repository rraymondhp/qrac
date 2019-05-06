{
  "apiVersion": "string",
  "kind": "string",
  "metadata": {
    "annotations": {
      "additionalProp1": "string",
      "additionalProp2": "string",
      "additionalProp3": "string"
    },
    "clusterName": "string",
    "creationTimestamp": "2019-05-02T07:40:48.963Z",
    "deletionGracePeriodSeconds": 0,
    "deletionTimestamp": "2019-05-02T07:40:48.963Z",
    "finalizers": [
      "string"
    ],
    "generateName": "string",
    "generation": 0,
    "initializers": {
      "pending": [
        {
          "name": "string"
        }
      ],
      "result": {
        "apiVersion": "string",
        "code": 0,
        "details": {
          "causes": [
            {
              "field": "string",
              "message": "string",
              "reason": "string"
            }
          ],
          "group": "string",
          "kind": "string",
          "name": "string",
          "retryAfterSeconds": 0,
          "uid": "string"
        },
        "kind": "string",
        "message": "string",
        "metadata": {
          "continue": "string",
          "resourceVersion": "string",
          "selfLink": "string"
        },
        "reason": "string",
        "status": "string"
      }
    },
    "labels": {
      "additionalProp1": "string",
      "additionalProp2": "string",
      "additionalProp3": "string"
    },
    "name": "string",
    "namespace": "string",
    "ownerReferences": [
      {
        "apiVersion": "string",
        "blockOwnerDeletion": true,
        "controller": true,
        "kind": "string",
        "name": "string",
        "uid": "string"
      }
    ],
    "resourceVersion": "string",
    "selfLink": "string",
    "uid": "string"
  },
  "spec": {
    "extra": {
      "additionalProp1": [
        "string"
      ],
      "additionalProp2": [
        "string"
      ],
      "additionalProp3": [
        "string"
      ]
    },
    "group": [
      "string"
    ],
    "nonResourceAttributes": {
      "path": "string",
      "verb": "string"
    },
    "resourceAttributes": {
      "group": "string",
      "name": "string",
      "namespace": "string",
      "resource": "string",
      "subresource": "string",
      "verb": "string",
      "version": "string"
    },
    "uid": "string",
    "user": "string"
  },
  "status": {
    "allowed": true,
    "denied": true,
    "evaluationError": "string",
    "reason": "string"
  }
}