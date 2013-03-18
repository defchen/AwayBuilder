package awaybuilder.view.mediators
{
    import away3d.containers.ObjectContainer3D;
    import away3d.core.base.Geometry;
import away3d.core.base.SubMesh;
import away3d.entities.Mesh;
import away3d.materials.MaterialBase;
import away3d.materials.TextureMaterial;
import away3d.textures.BitmapTexture;

import awaybuilder.controller.events.DocumentModelEvent;
    import awaybuilder.controller.events.SceneEvent;
    import awaybuilder.model.IDocumentModel;
import awaybuilder.model.vo.BitmapTextureVO;
import awaybuilder.model.vo.MaterialItemVO;
import awaybuilder.model.vo.MeshItemVO;
import awaybuilder.model.vo.ScenegraphGroupItemVO;
import awaybuilder.model.vo.SubMeshVO;
import awaybuilder.model.vo.SubMeshVO;
import awaybuilder.model.vo.TextureMaterialVO;
import awaybuilder.view.components.PropertiesPanel;
    import awaybuilder.view.components.propertyEditors.PropertyEditorEvent;

    import flash.geom.Vector3D;

    import org.robotlegs.mvcs.Mediator;

    public class PropertiesPanelMediator extends Mediator
    {
        [Inject]
        public var view:PropertiesPanel;

        [Inject]
        public var document:IDocumentModel;

        override public function onRegister():void
        {
            addContextListener(DocumentModelEvent.DOCUMENT_UPDATED, eventDispatcher_documentUpdatedHandler, DocumentModelEvent);
            addContextListener(SceneEvent.ITEMS_SELECT, eventDispatcher_itemsSelectHandler, SceneEvent);
            addContextListener(SceneEvent.CHANGING, eventDispatcher_changingHandler, SceneEvent);
            addContextListener(SceneEvent.TRANSLATE_OBJECT, eventDispatcher_changeMeshHandler, SceneEvent);
            addContextListener(SceneEvent.SCALE_OBJECT, eventDispatcher_changeMeshHandler, SceneEvent);
            addContextListener(SceneEvent.ROTATE_OBJECT, eventDispatcher_changeMeshHandler, SceneEvent);
            addContextListener(SceneEvent.CHANGE_MESH, eventDispatcher_changeMeshHandler, SceneEvent);
            addContextListener(SceneEvent.CHANGE_MATERIAL, eventDispatcher_changeMaterialHandler, SceneEvent);

            addViewListener( PropertyEditorEvent.TRANSLATE, view_translateHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.ROTATE, view_rotateHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.SCALE, view_scaleHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.MESH_CHANGE, view_meshChangeHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.MESH_NAME_CHANGE, view_meshNameChangeHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.MESH_SUBMESH_CHANGE, view_meshSubmeshChangeHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.MATERIAL_CHANGE, view_materialChangeHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.MATERIAL_NAME_CHANGE, view_materialNameChangeHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.SHOW_MATERIAL_PROPERTIES, view_showMaterialPropertiesHandler, PropertyEditorEvent );
            addViewListener( PropertyEditorEvent.SHOW_TEXTURE_PROPERTIES, view_showTexturePropertiesHandler, PropertyEditorEvent );
        }

        //----------------------------------------------------------------------
        //
        //	view handlers
        //
        //----------------------------------------------------------------------


        private function view_translateHandler(event:PropertyEditorEvent):void
        {
            var vo:MeshItemVO = view.data as MeshItemVO;
            var oldValue:Vector3D = new Vector3D( vo.x, vo.y, vo.z );
            this.dispatch(new SceneEvent(SceneEvent.TRANSLATE_OBJECT,[vo.item],oldValue, event.data, true));
        }
        private function view_rotateHandler(event:PropertyEditorEvent):void
        {
            var vo:MeshItemVO = view.data as MeshItemVO;
            var oldValue:Vector3D = new Vector3D( vo.rotationX, vo.rotationY, vo.rotationZ );
            this.dispatch(new SceneEvent(SceneEvent.ROTATE_OBJECT,[vo.item],oldValue, event.data, true));
        }
        private function view_scaleHandler(event:PropertyEditorEvent):void
        {
            var vo:MeshItemVO = view.data as MeshItemVO;
            var oldValue:Vector3D = new Vector3D( vo.scaleX, vo.scaleY, vo.scaleZ );
            this.dispatch(new SceneEvent(SceneEvent.SCALE_OBJECT,[vo.item],oldValue, event.data, true));
        }
        private function view_meshChangeHandler(event:PropertyEditorEvent):void
        {
            var vo:MeshItemVO = view.data as MeshItemVO;
            var oldValue:MeshItemVO = new MeshItemVO( vo.item as Mesh );
            this.dispatch(new SceneEvent(SceneEvent.CHANGE_MESH,[vo.item],oldValue, event.data));
        }
        private function view_meshNameChangeHandler(event:PropertyEditorEvent):void
        {
            var vo:MeshItemVO = view.data as MeshItemVO;
            var oldValue:MeshItemVO = new MeshItemVO( vo.item as Mesh );
            this.dispatch(new SceneEvent(SceneEvent.CHANGE_MESH,[vo.item],oldValue, event.data, true));
        }
        private function view_meshSubmeshChangeHandler(event:PropertyEditorEvent):void
        {
            var vo:MeshItemVO = view.data as MeshItemVO;
            var oldValue:MeshItemVO = new MeshItemVO( vo.item as Mesh );
            var newValue:MeshItemVO = new MeshItemVO( vo.item as Mesh );
            for each( var subMesh:SubMeshVO in newValue.subMeshes )
            {
                if( subMesh.linkedObject == SubMeshVO(event.data).linkedObject )
                {
                    subMesh.material = SubMeshVO(event.data).material;
                }
            }
            this.dispatch(new SceneEvent(SceneEvent.CHANGE_MESH,[vo.item],oldValue, newValue));
        }
        private function view_materialChangeHandler(event:PropertyEditorEvent):void
        {
            var vo:MaterialItemVO = view.data as MaterialItemVO;
            var oldValue:MaterialItemVO = new MaterialItemVO( vo.item as MaterialBase );
            this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[vo.item],oldValue, event.data));
        }
        private function view_materialNameChangeHandler(event:PropertyEditorEvent):void
        {
            var vo:MaterialItemVO = view.data as MaterialItemVO;
            var oldValue:MaterialItemVO = new MaterialItemVO( vo.item as MaterialBase );
            this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[vo.item],oldValue, event.data, true));
        }

        private function view_showMaterialPropertiesHandler(event:PropertyEditorEvent):void
        {
            this.dispatch(new SceneEvent(SceneEvent.ITEMS_SELECT,[event.data]));

        }
        private function view_showTexturePropertiesHandler(event:PropertyEditorEvent):void
        {
            this.dispatch(new SceneEvent(SceneEvent.ITEMS_SELECT,[event.data]));
        }

        //----------------------------------------------------------------------
        //
        //	context handlers
        //
        //----------------------------------------------------------------------

        private function eventDispatcher_documentUpdatedHandler(event:DocumentModelEvent):void
        {

        }

        private function eventDispatcher_changeMeshHandler(event:SceneEvent):void
        {
            var mesh:MeshItemVO = new MeshItemVO( event.items[0] );

            for each( var subMesh:SubMeshVO in  mesh.subMeshes )
            {
                subMesh.linkedMaterials = document.getScenegraphGroup(ScenegraphGroupItemVO.MATERIAL_GROUP).children;
            }

            view.data = mesh;
        }
        private function eventDispatcher_changeMaterialHandler(event:SceneEvent):void
        {
            trace( view.data );
            view.data = new TextureMaterialVO( event.items[0] );
        }
        private function eventDispatcher_changingHandler(event:SceneEvent):void
        {
            var mesh:Mesh = event.items[0] as Mesh;
            var vo:MeshItemVO = view.data as MeshItemVO;
            vo.x = mesh.x;
            vo.y = mesh.y;
            vo.z = mesh.z;

            vo.scaleX = mesh.scaleX;
            vo.scaleY = mesh.scaleY;
            vo.scaleZ = mesh.scaleZ;

            vo.rotationX = mesh.rotationX;
            vo.rotationY = mesh.rotationY;
            vo.rotationZ = mesh.rotationZ;

        }
        private function eventDispatcher_itemsSelectHandler(event:SceneEvent):void
        {
            if( !event.items || event.items.length == 0)
            {
                view.visible = false;
                return;
            }
            if( event.items.length )
            {
                if( event.items.length == 1 )
                {
                    if( event.items[0] is Mesh )
                    {
                        var mesh:MeshItemVO = new MeshItemVO( event.items[0] );
                        for each( var subMesh:SubMeshVO in  mesh.subMeshes )
                        {
                            if( document.getScenegraphGroup(ScenegraphGroupItemVO.MATERIAL_GROUP) ) {
                                subMesh.linkedMaterials = document.getScenegraphGroup(ScenegraphGroupItemVO.MATERIAL_GROUP).children;
                            }
                        }
                        view.data = mesh;
                        view.currentState = "mesh";
                    }
                    else if( event.items[0] is ObjectContainer3D )
                    {
                        view.currentState = "container";
                       // view.data = new MeshItemVO( event.items[0] );
                    }
                    else if( event.items[0] is TextureMaterial )
                    {

                        var material:TextureMaterialVO = new TextureMaterialVO( event.items[0] );
                        if( document.getScenegraphGroup(ScenegraphGroupItemVO.TEXTURE_GROUP) ) {
                            material.linkedTextures = document.getScenegraphGroup(ScenegraphGroupItemVO.TEXTURE_GROUP).children;
                        }
                        view.data = material;
                        view.currentState = "material";
                    }
                    else if( event.items[0] is BitmapTexture )
                    {
                        view.currentState = "texture";
                        view.data = new BitmapTextureVO( event.items[0] );
                    }
                    else if( event.items[0] is Geometry )
                    {
                        view.currentState = "geometry";
                    }
                    else
                    {
                        view.visible = false;
                    }
                }
                else
                {
                    view.currentState = "group"
                }
                view.visible = true;
            }
            else
            {
                view.visible = false;
            }

        }

    }
}