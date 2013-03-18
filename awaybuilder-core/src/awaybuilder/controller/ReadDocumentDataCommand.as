package awaybuilder.controller
{
import away3d.materials.MaterialBase;

import awaybuilder.model.vo.BitmapTextureVO;

import awaybuilder.model.vo.MaterialItemVO;
import awaybuilder.model.vo.MeshItemVO;
import awaybuilder.model.vo.TextureMaterialVO;

import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	
	import away3d.animators.AnimationSetBase;
	import away3d.animators.AnimationStateBase;
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonPose;
	import away3d.animators.nodes.AnimationNodeBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.textures.BitmapTexture;
	
	import awaybuilder.controller.events.ReadDocumentDataEvent;
	import awaybuilder.model.IDocumentModel;
	import awaybuilder.model.UndoRedoModel;
	import awaybuilder.model.vo.ScenegraphGroupItemVO;
	import awaybuilder.model.vo.ScenegraphItemVO;
	import awaybuilder.utils.scene.Scene3DManager;
	
	import org.robotlegs.mvcs.Command;

	public class ReadDocumentDataCommand extends Command
	{

		[Inject]
		public var document:IDocumentModel;
		
		[Inject]
		public var undoRedo:UndoRedoModel;
		
		[Inject]
		public var event:ReadDocumentDataEvent;
		
		
		private var _scenegraph:ArrayCollection;
		
		private var _sceneGroup:ScenegraphGroupItemVO;
		
		private var _materialGroup:ScenegraphGroupItemVO;
		
		private var _animationGroup:ScenegraphGroupItemVO;
		
		private var _geometryGroup:ScenegraphGroupItemVO;
		
		private var _textureGroup:ScenegraphGroupItemVO;

        private var _skeletonGroup:ScenegraphGroupItemVO;

		override public function execute():void
		{
			_scenegraph = document.scenegraph;
			
			_sceneGroup = document.getScenegraphGroup( ScenegraphGroupItemVO.SCENE_GROUP );
			if( !_sceneGroup ) 
			{
				_sceneGroup = new ScenegraphGroupItemVO( "Scene", ScenegraphGroupItemVO.SCENE_GROUP );
			}
			_materialGroup = document.getScenegraphGroup( ScenegraphGroupItemVO.MATERIAL_GROUP );
			if( !_materialGroup ) 
			{
				_materialGroup = new ScenegraphGroupItemVO( "Materials", ScenegraphGroupItemVO.MATERIAL_GROUP );
			}
			_animationGroup = document.getScenegraphGroup( ScenegraphGroupItemVO.ANIMATION_GROUP );
			if( !_animationGroup ) 
			{
				_animationGroup = new ScenegraphGroupItemVO( "Animations", ScenegraphGroupItemVO.ANIMATION_GROUP );
			}
			_geometryGroup = document.getScenegraphGroup( ScenegraphGroupItemVO.GEOMETRY_GROUP );
			if( !_geometryGroup ) 
			{
				_geometryGroup = new ScenegraphGroupItemVO( "Geometry", ScenegraphGroupItemVO.GEOMETRY_GROUP );
			}
			_textureGroup = document.getScenegraphGroup( ScenegraphGroupItemVO.TEXTURE_GROUP );
			if( !_textureGroup ) 
			{
				_textureGroup = new ScenegraphGroupItemVO( "Texture", ScenegraphGroupItemVO.TEXTURE_GROUP );
			}
            _skeletonGroup = document.getScenegraphGroup( ScenegraphGroupItemVO.SKELETON_GROUP );
            if( !_skeletonGroup )
            {
                _skeletonGroup = new ScenegraphGroupItemVO( "Skeleton", ScenegraphGroupItemVO.SKELETON_GROUP );
            }
			
			document.name = event.name;
			Parsers.enableAllBundled();
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, assetCompleteHandler);		
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, resourceCompleteHandler);
			AssetLibrary.addEventListener(LoaderEvent.LOAD_ERROR, loadErrorHandler);
			AssetLibrary.load(new URLRequest(event.path));	
			CursorManager.setBusyCursor();
		}
		
		
		private function loadErrorHandler( event:LoaderEvent ):void
		{
			Alert.show( event.message, "Resource not loaded" );
		}
		
		private function resourceCompleteHandler( event:LoaderEvent ):void
		{
			if( _animationGroup.children.length && !document.getScenegraphGroup( ScenegraphGroupItemVO.ANIMATION_GROUP ) ) 
			{
				_scenegraph.addItem( _animationGroup );
			}
			if( _geometryGroup.children.length && !document.getScenegraphGroup( ScenegraphGroupItemVO.GEOMETRY_GROUP ) ) 
			{
				_scenegraph.addItem( _geometryGroup );
			}
			if( _sceneGroup.children.length && !document.getScenegraphGroup( ScenegraphGroupItemVO.SCENE_GROUP ) ) 
			{
				_scenegraph.addItem( _sceneGroup );
			}
			if( _textureGroup.children.length && !document.getScenegraphGroup( ScenegraphGroupItemVO.TEXTURE_GROUP ) ) 
			{
				_scenegraph.addItem( _textureGroup );
			}
			if( _materialGroup.children.length && !document.getScenegraphGroup( ScenegraphGroupItemVO.MATERIAL_GROUP ) ) 
			{
				_scenegraph.addItem( _materialGroup );
			}
            if( _skeletonGroup.children.length && !document.getScenegraphGroup( ScenegraphGroupItemVO.SKELETON_GROUP ) )
            {
                _scenegraph.addItem( _skeletonGroup );
            }
			
//			trace( _mesh.parent );
//			if( _mesh.material ) {
//				Scene3DManager.addMesh( _mesh );
//			}
//			else {
//				Alert.show( "Mesh was not added to scene, material is undefined", "Warning" ); 
//			}
			CursorManager.removeBusyCursor();
		}
		private function assetCompleteHandler( event:AssetEvent ):void
		{		
				
//			trace( event.asset.assetType );
			
//			var _light:DirectionalLight = new DirectionalLight(-1, -1, 1);
////			_direction = new Vector3D(-1, -1, 1);
//			var _lightPicker:StaticLightPicker = new StaticLightPicker([_light]);
//			Scene3DManager.addLight( _light );
//			
			var item:ScenegraphItemVO;

            switch( event.asset.assetType )
            {
                case AssetType.MESH:
                    var mesh:Mesh = event.asset as Mesh;
                    if( !mesh.material )
                    {
                        mesh.material = DefaultMaterialManager.getDefaultMaterial();
                        item = new MaterialItemVO( mesh.material );
                        _materialGroup.children.addItem( item );
                    }

                    item = new MeshItemVO( mesh );
                    _sceneGroup.children.addItem( item );
                    Scene3DManager.addMesh( mesh );
                    break;
                case AssetType.CONTAINER:
                    var c:ObjectContainer3D = event.asset as ObjectContainer3D;
                    item = new ScenegraphItemVO( c.name, c );
                    item.children = new ArrayCollection();
                    _sceneGroup.children.addItem( item );
                    break;
                case AssetType.MATERIAL:
                    var material:TextureMaterial = event.asset as TextureMaterial;
                    if( material )
                    {
                        item = new TextureMaterialVO( material );
                        _materialGroup.children.addItem( item );
                    }
                    else
                    {
                        trace( "MATERIAL asset = " + event.asset );
                    }
                    break;
                case AssetType.TEXTURE:
                    var texture:BitmapTexture = event.asset as BitmapTexture;
                    item = new BitmapTextureVO( texture );
                    _textureGroup.children.addItem( item );
                    break;
                case AssetType.GEOMETRY:
                    var geometry:Geometry = event.asset as Geometry;
                    item = new ScenegraphItemVO( geometry.name ,geometry );
                    _geometryGroup.children.addItem( item );
                    break;
                case AssetType.ANIMATION_SET:
                    var animationSet:AnimationSetBase = event.asset as AnimationSetBase;
                    item = new ScenegraphItemVO( "Animation Set (" + animationSet.name +")",animationSet );
                    _animationGroup.children.addItem( item );
                    break;
                case AssetType.ANIMATION_STATE:
                    var animationState:AnimationStateBase = event.asset as AnimationStateBase;
                    item = new ScenegraphItemVO( "Animation State (" + animationState.name +")",animationState );
                    _animationGroup.children.addItem( item );
                    break;
                case AssetType.ANIMATION_NODE:
                    var animationNode:AnimationNodeBase = event.asset as AnimationNodeBase;
                    item = new ScenegraphItemVO( "Animation Node (" + animationNode.name +")",animationNode );
                    _animationGroup.children.addItem( item );
                    break;
                case AssetType.SKELETON:
                    var s:Skeleton = event.asset as Skeleton;
                    item = new ScenegraphItemVO( "Skeleton (" + s.name +")",s );
                    _skeletonGroup.children.addItem( item );
                    break;
                case AssetType.SKELETON_POSE:
                    var sp:SkeletonPose = event.asset as SkeletonPose;
                    item = new ScenegraphItemVO( "Skeleton Pose (" + sp.name +")",sp );
                    _skeletonGroup.children.addItem( item );
                    break;
            }
		}

	}
}