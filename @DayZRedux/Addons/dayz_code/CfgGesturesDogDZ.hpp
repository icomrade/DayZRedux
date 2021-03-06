// Generated by unRap v1.06 by Kegetys

class CfgGesturesDogDZ {
	skeletonName = "DogSkeleton";
	
	class ManActions {};
	
	class Actions {
		class NoActions : ManActions {
			turnSpeed = 0;
			upDegree = 0;
			limitFast = 1;
			useFastMove = 0;
		};
	};
	
	class Default {
		actions = "NoActions";
		file = "";
		looped = true;
		speed = 0.5;
		relSpeedMin = 1;
		relSpeedMax = 1;
		soundEnabled = false;
		soundOverride = "";
		soundEdge[] = {0.5, 1};
		terminal = false;
		equivalentTo = "";
		connectAs = "";
		connectFrom[] = {};
		connectTo[] = {};
		interpolateWith[] = {};
		interpolateTo[] = {};
		interpolateFrom[] = {};
		mask = "empty";
		interpolationSpeed = 6;
		interpolationRestart = false;
		preload = false;
		disableWeapons = true;
		enableOptics = true;
		showWeaponAim = true;
		enableMissile = true;
		enableBinocular = true;
		showItemInHand = false;
		showItemInRightHand = false;
		showHandGun = false;
		canPullTrigger = true;
		walkcycles = 1;
		headBobMode = 0;
		headBobStrength = 0;
		leftHandIKBeg = false;
		leftHandIKEnd = false;
		rightHandIKBeg = false;
		rightHandIKEnd = false;
		leftHandIKCurve[] = {1};
		rightHandIKCurve[] = {1};
		forceAim = 0;
	};
	
	class States {
		class GestureBark : Default {
			file = "\dayz_anim\dog\dogBarkOnce";
			looped = false;
			speed = 3;
			mask = "barking";
		};
		
		class GestureIdle1 : Default {
			file = "\dayz_anim\dog\dogGestureIdle1";
			looped = false;
			speed = 0.3;
			mask = "idle";
		};
		
		class GestureIdle2 : Default {
			file = "\dayz_anim\dog\dogGestureIdle2";
			looped = false;
			speed = 0.3;
			mask = "idle";
		};
		
		class GestureSniff : Default {
			file = "\dayz_anim\dog\dogGestureSniff";
			looped = false;
			speed = 0.3;
			mask = "frontBody";
		};
	};
	
	class BlendAnims {
		barking[] = {"head", 1, "Jaw", 1, "Neck1", 0.5, "Tongue1", 1, "Tongue2", 1, "Tail1", 0.3, "Tail2", 0.6, "Tail3", 1};
		idle[] = {"head", 1, "Jaw", 1, "Neck1", 0.6, "Tongue1", 1, "Tongue2", 1, "Tail1", 0.3, "Tail2", 0.6, "Tail3", 1, "Spine", 0.1, "Spine1", 0.2, "Spine2", 0.4};
		frontBody[] = {"spine", 0.1, "spine1", 0.3, "spine2", 0.6, "neck", 1, "neck1", 1, "head", 1, "Jaw", 1, "Tongue1", 1, "Tongue2", 1, "leftArm", 0.5, "rightArm", 0.5, "leftEar", 1, "rightEar", 1};
	};
	
	class Interpolations {};
	transitionsInterpolated[] = {};
	transitionsSimple[] = {};
	transitionsDisabled[] = {};
};
