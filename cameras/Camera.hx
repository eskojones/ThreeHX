
package three.cameras;

import three.core.Object3D;
import three.math.Matrix4;
import three.math.Vector3;

/**
 * Base Camera
 * @author dcm
 */

class Camera extends Object3D
{
	
	public var matrixWorldInverse:Matrix4;
	public var projectionMatrix:Matrix4;
	public var projectionMatrixInverse:Matrix4;

	
	public function new() 
	{
		super();
		matrixWorldInverse = new Matrix4();
		projectionMatrix = new Matrix4();
		projectionMatrixInverse = new Matrix4();
		visible = false;
	}
	
	
	override public function lookAt (v:Vector3)
	{
		var m1 = new Matrix4();
		m1.lookAt(position, v, up);
		if (useQuaternion == true) quaternion.setFromRotationMatrix(m1);
		else rotation.setEulerFromRotationMatrix(m1, eulerOrder);
	}
	
}

