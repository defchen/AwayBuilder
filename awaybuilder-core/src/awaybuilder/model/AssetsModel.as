package awaybuilder.model
{
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.lights.shadowmaps.CubeMapShadowMapper;
	import away3d.lights.shadowmaps.DirectionalShadowMapper;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.AlphaMaskMethod;
	import away3d.materials.methods.AnisotropicSpecularMethod;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.CascadeShadowMapMethod;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	import away3d.materials.methods.ColorMatrixMethod;
	import away3d.materials.methods.ColorTransformMethod;
	import away3d.materials.methods.DitheredShadowMapMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.GradientDiffuseMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.HeightMapNormalMethod;
	import away3d.materials.methods.LightMapDiffuseMethod;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.PhongSpecularMethod;
	import away3d.materials.methods.RefractionEnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.materials.methods.WrapDiffuseMethod;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.CubeTextureBase;
	import away3d.textures.Texture2DBase;
	
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.EffectMethodVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.ShadingMethodVO;
	import awaybuilder.model.vo.scene.ShadowMapperVO;
	import awaybuilder.model.vo.scene.ShadowMethodVO;
	import awaybuilder.model.vo.scene.TextureVO;
	import awaybuilder.utils.AssetUtil;
	
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;

	public class AssetsModel extends SmartFactoryModelBase
	{
		public function GetObjectsByType( type:Class, property:String=null, value:Object=null ):Vector.<Object> 
		{
			var objects:Vector.<Object> = new Vector.<Object>();
			for (var object:Object in _assets)
			{
				if( object is type )
				{
					if( property )
					{
						if( (object[property] == value) ) 
						{
							objects.push( object );
						}
					}
					else 
					{
						objects.push( object );
					}
				}
			}
			return objects;
		}
		public function RemoveObject( obj:Object ):void 
		{
			var asset:AssetVO = _assets[obj] as AssetVO;
			delete _objectsByAsset[asset];
			delete _assets[obj];
		}
		public function ReplaceObject( oldObject:Object, newObject:Object ):void 
		{
			var asset:AssetVO = _assets[oldObject];
			
			_objectsByAsset[asset] = newObject;
			_assets[newObject] = asset;
			
			delete _assets[oldObject];
		}
		public function GetObject( asset:AssetVO ):Object 
		{
			if( !asset ) return null;
			return _objectsByAsset[asset];
		}
		override public function GetAsset( obj:Object ):AssetVO
		{
			if( !obj ) return null;
			
			if( _assets[obj] ) return _assets[obj];
			
			var asset:AssetVO = createAsset( obj );
			asset.id = UIDUtil.createUID();
			
			_assets[obj] = asset;
			_objectsByAsset[asset] = obj;
			return asset;
		}
		
		public function CreateMaterial( clone:MaterialVO = null ):MaterialVO
		{
			if( !clone )
			{
				clone = GetDefaultMaterial();
			}
			var newMaterial:SinglePassMaterialBase;
			var textureMaterial:TextureMaterial = GetObject(clone) as TextureMaterial;
			newMaterial = new TextureMaterial( textureMaterial.texture, textureMaterial.smooth, textureMaterial.repeat, textureMaterial.mipmap );
			newMaterial.name = "Material " + AssetUtil.GetNextId("Material");
			return GetAsset(newMaterial) as MaterialVO;
		}
		
		public function CreateEffectMethod( type:String ):EffectMethodVO
		{
			var method:EffectMethodBase;
			switch( type )
			{
				case "LightMapMethod":
					method = new LightMapMethod(GetObject(_defaultTexture) as Texture2DBase);
					method.name =  "LightMap " + AssetUtil.GetNextId("LightMapMethod");
					break;
				case "ProjectiveTextureMethod":
//					method = new ProjectiveTextureMethod();
//					method.name =  "LightMapMethod " + AssetUtil.GetNextId("LightMapMethod");
					break;
				case "RimLightMethod":
					method = new RimLightMethod();
					method.name =  "RimLight " + AssetUtil.GetNextId("RimLightMethod");
					break;
				case "ColorTransformMethod":
					method = new ColorTransformMethod();
					ColorTransformMethod(method).colorTransform = new ColorTransform();
					method.name =  "ColorTransform " + AssetUtil.GetNextId("ColorTransformMethod");
					break;
				case "AlphaMaskMethod":
					method = new AlphaMaskMethod(GetObject(_defaultTexture) as Texture2DBase, false);
					method.name =  "AlphaMask " + AssetUtil.GetNextId("AlphaMaskMethod");
					break;
				case "ColorMatrixMethod":
					method = new ColorMatrixMethod([ 0.2225, 0.7169, 0.0606, 0, 0, 0.2225, 0.7169, 0.0606, 0, 0, 0.2225, 0.7169, 0.0606, 0, 0, 0, 0, 0, 1, 1]);
					method.name =  "ColorMatrix " + AssetUtil.GetNextId("ColorMatrixMethod");
					break;
				case "RefractionEnvMapMethod":
					method = new RefractionEnvMapMethod( GetObject(_defaultCubeTexture) as CubeTextureBase );
					method.name =  "RefractionEnvMap " + AssetUtil.GetNextId("RefractionEnvMapMethod");
					break;
				case "OutlineMethod":
					method = new OutlineMethod();
					method.name =  "Outline " + AssetUtil.GetNextId("OutlineMethod");
					break;
				case "FresnelEnvMapMethod":
					method = new FresnelEnvMapMethod( GetObject(_defaultCubeTexture) as CubeTextureBase );
					method.name =  "FresnelEnvMap " + AssetUtil.GetNextId("FresnelEnvMapMethod");
					break;
				case "FogMethod":
					method = new FogMethod(0,1000);
					method.name =  "Fog " + AssetUtil.GetNextId("FogMethod");
					break;
				case "EnvMapMethod":
					method = new EnvMapMethod( GetObject(_defaultCubeTexture) as CubeTextureBase );
					method.name =  "EnvMap " + AssetUtil.GetNextId("EnvMapMethod");
					break;
			}
			return GetAsset( method ) as EffectMethodVO;
		}
		public function CreateCubeTexture():CubeTextureVO
		{
			var light:BitmapCubeTexture = new BitmapCubeTexture( getChekerboard(0xFFFFFF), getChekerboard(0xAAAAAA), getChekerboard(0xEEEEEE), getChekerboard(0xDDDDDD), getChekerboard(0xCCCCCC), getChekerboard(0xBBBBBB) );
			light.name = "Cube " + AssetUtil.GetNextId("Cube");
			return GetAsset( light ) as CubeTextureVO;
		}
		public function CreateDirectionalLight():LightVO
		{
			var light:DirectionalLight = new DirectionalLight();
			light.name = "DirectionalLight " + AssetUtil.GetNextId("directionalLight");
			light.castsShadows = false;
			return GetAsset( light ) as LightVO;
		}
		public function CreatePointLight():LightVO
		{
			var light:PointLight = new PointLight();
			light.name = "PointLight " + AssetUtil.GetNextId("pointLight");
			light.castsShadows = false;
			return GetAsset( light ) as LightVO;
		}
		public function CreateLightPicker():LightPickerVO
		{
			var lightPicker:StaticLightPicker = new StaticLightPicker([]);
			lightPicker.name = "Light Picker " + AssetUtil.GetNextId("lightPicker");
			return GetAsset( lightPicker ) as LightPickerVO;
		}
		
		public function CreateFilteredShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:FilteredShadowMapMethod = new FilteredShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "FilteredShadow " + AssetUtil.GetNextId("FilteredShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateDitheredShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:DitheredShadowMapMethod = new DitheredShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "DitheredShadow " + AssetUtil.GetNextId("DitheredShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateSoftShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:SoftShadowMapMethod = new SoftShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "SoftShadow " + AssetUtil.GetNextId("SoftShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateHardShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:HardShadowMapMethod = new HardShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "HardShadow " + AssetUtil.GetNextId("HardShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateNearShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var simple:SoftShadowMapMethod = new SoftShadowMapMethod( GetObject(light) as DirectionalLight );
			var method:NearShadowMapMethod = new NearShadowMapMethod( simple );
			method.name = "NearShadow " + AssetUtil.GetNextId("NearShadowMapMethod");
			var asset:ShadowMethodVO = GetAsset( method ) as ShadowMethodVO;;
			asset.baseMethod = GetAsset( simple ) as ShadowMethodVO;
			return asset;
		}
		public function CreateCascadeShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var simple:SoftShadowMapMethod = new SoftShadowMapMethod( GetObject(light) as DirectionalLight );
			var method:CascadeShadowMapMethod = new CascadeShadowMapMethod( simple );
			method.name = "CascadeShadow " + AssetUtil.GetNextId("CascadeShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateShadingMethod( type:String ):ShadingMethodVO
		{
			var baseMethod:ShadingMethodBase;
			var method:ShadingMethodBase;
			switch( type )
			{
				case "EnvMapAmbientMethod":
					method = new EnvMapAmbientMethod(GetObject(_defaultCubeTexture) as CubeTextureBase);
					break;
				case "BasicDiffuseMethod":
					method = new BasicDiffuseMethod();
					break;
				case "GradientDiffuseMethod":
					method = new GradientDiffuseMethod(GetObject(_defaultTexture) as Texture2DBase);
					break;
				case "WrapDiffuseMethod":
					method = new WrapDiffuseMethod();
					break;
				case "LightMapDiffuseMethod":
					baseMethod = new BasicDiffuseMethod();
					method = new LightMapDiffuseMethod(GetObject(_defaultTexture) as Texture2DBase,"multiply",false, baseMethod as BasicDiffuseMethod);
					break;
				case "CelDiffuseMethod":
					baseMethod = new BasicDiffuseMethod();
					method = new CelDiffuseMethod(3,baseMethod as BasicDiffuseMethod);
					break;
				case "SubsurfaceScatteringDiffuseMethod":
					baseMethod = new BasicDiffuseMethod();
					method = new SubsurfaceScatteringDiffuseMethod();
					SubsurfaceScatteringDiffuseMethod(method).baseMethod = baseMethod as BasicDiffuseMethod;
					break;
				case "BasicSpecularMethod":
					method = new BasicSpecularMethod();
					break;
				case "AnisotropicSpecularMethod":
					method = new AnisotropicSpecularMethod();
					break;
				case "PhongSpecularMethod":
					method = new PhongSpecularMethod();
					break;
				case "CelSpecularMethod":
					method = new CelSpecularMethod();
					break;
				case "FresnelSpecularMethod":
					baseMethod = new BasicSpecularMethod();
					method = new FresnelSpecularMethod( true, baseMethod as BasicSpecularMethod );
					break;
				case "BasicNormalMethod":
					method = new BasicNormalMethod();
					break;
				case "HeightMapNormalMethod":
					method = new HeightMapNormalMethod(GetObject(_defaultTexture) as Texture2DBase,5,5,5);
					break;
				case "SimpleWaterNormalMethod":
					method = new SimpleWaterNormalMethod(GetObject(_defaultTexture) as Texture2DBase,GetObject(_defaultTexture) as Texture2DBase);
					break;
				
			}
			return GetAsset( method ) as ShadingMethodVO;
		}
		public function CreateShadowMapper( type:String ):ShadowMapperVO
		{
			var mapper:ShadowMapperBase;
			switch( type )
			{
				case "DirectionalShadowMapper":
					mapper = new DirectionalShadowMapper();
					break;
				case "CascadeShadowMapper":
					mapper = new CascadeShadowMapper();
					break;
				case "NearDirectionalShadowMapper":
					mapper = new NearDirectionalShadowMapper();
					break;
				case "CubeMapShadowMapper":
					mapper = new CubeMapShadowMapper();
					break;
			}
			
			return GetAsset( mapper ) as ShadowMapperVO;
		}
		
		//-- Defaults ---
		
		public function GetDefaultMaterial():MaterialVO
		{
			createDefaults();
			return _defaultMaterial;
		}
		public function GetDefaultTexture():TextureVO
		{
			createDefaults();
			return _defaultTexture;
		}
		public function GetDefaultCubeTexture():CubeTextureVO
		{
			createDefaults();
			return _defaultCubeTexture;
		}
		public function Clear():void
		{
			_defaultMaterial = null;
			_defaultTexture = null;
			_assets = new Dictionary();
			_objectsByAsset = new Dictionary();
			AssetUtil.Clear();
		}
		
	}
}