package awaybuilder.web.model
{
	import awaybuilder.controller.history.HistoryEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.IDocumentService;
	import awaybuilder.model.SmartDocumentServiceBase;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.TextureVO;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	
	import mx.managers.CursorManager;
	
	public class DocumentService extends SmartDocumentServiceBase implements IDocumentService
	{
		private static const FILE_EXTENSION : String = '.awd';
		
		private var _nextEvent:HistoryEvent;
		
		private var _items:Array;
		
		private var _name:String;
		
		private var _property:String;
		
		private var _fileToData:Dictionary = new Dictionary();
		
		private var _file:FileReference;
		
		public function load( url:String, name:String, event:HistoryEvent ):void
		{
			_name = name;
			_nextEvent = event;
			loadAssets( url );
		}
		
		public function openBitmap( items:Array, property:String ):void
		{
			_file = new FileReference();
			_items = items;
			_property = property;
			_file.addEventListener(Event.SELECT, bitmapFile_open_selectHandler);
			_file.addEventListener(Event.CANCEL, bitmapFile_open_cancelHandler);
			var filters:Array = [];
			var title:String = "Import Bitmap";
			filters.push( new FileFilter("Bitmap (*.png, *.jpg)", "*.png;*.jpg") );
			_file.browse(filters);
		}
		
		public function open( type:String, event:HistoryEvent ):void
		{
			_nextEvent = event;
			_file = new FileReference();
			_file.addEventListener(Event.SELECT, file_open_selectHandler);
			_file.addEventListener(Event.CANCEL, file_open_cancelHandler);
			var filters:Array = [];
			var title:String;
			switch( type ) 
			{
				case "open":
					title = "Open File";
					filters.push( new FileFilter("Away3D (*.awd)", "*.awd") );
					break;
				case "all":
					title = "Import File";
					filters.push( new FileFilter("3D and Images", "*.awd;*.3ds;*.obj;*.md2;*.png;*.jpg;*.dae") );
					filters.push( new FileFilter("3D (*.awd, *.3ds, *.obj, *.md2, *.dae)", "*.awd;*.3ds;*.obj;*.md2;*.dae") );
					filters.push( new FileFilter("Images (*.png, *.jpg)", "*.png;*.jpg") );
					break;
				case "images":
					title = "Import Texture";
					filters.push( new FileFilter("Images (*.png, *.jpg)", "*.png;*.jpg") );
					break;
			}
			_file.browse( filters);
		}
		
		public function saveAs(data:Object, defaultName:String):void
		{
		}
		
		public function save(data:Object, path:String):void
		{	
		}
		
		private function file_save_selectHandler(event:Event):void
		{
		}
		
		private function file_save_cancelHandler(event:Event):void
		{
		}
		
		private function bitmapFile_open_selectHandler(event:Event):void
		{
			_file.removeEventListener(Event.SELECT, bitmapFile_open_selectHandler);
			_file.removeEventListener(Event.CANCEL, bitmapFile_open_cancelHandler);
			_file.addEventListener(Event.COMPLETE, bitmapFile_open_completeHandler);
			_file.load();
		}
		private function bitmapFile_open_cancelHandler(event:Event):void
		{
			var file:FileReference = FileReference(event.currentTarget);
			file.removeEventListener(Event.SELECT, bitmapFile_open_selectHandler);
			file.removeEventListener(Event.CANCEL, bitmapFile_open_cancelHandler);
		}
		
		private function bitmapFile_open_completeHandler(event:Event):void
		{
			_file.removeEventListener(Event.COMPLETE, bitmapFile_open_completeHandler);
			parseBitmap( _file.data );
		}	
		private function file_open_selectHandler(event:Event):void
		{
			_file.removeEventListener(Event.SELECT, file_open_selectHandler);
			_file.removeEventListener(Event.CANCEL, file_open_cancelHandler);
			_file.addEventListener(Event.COMPLETE, file_open_completeHandler);
			_file.load();
		}
		
		private function file_open_completeHandler(event:Event):void 
		{
			_file.removeEventListener(Event.COMPLETE, file_open_completeHandler);
			parse( _file.data );
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void 
		{
			trace("httpStatusHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void 
		{
			var file:FileReference = FileReference(event.target);
			trace("progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		private function file_open_cancelHandler(event:Event):void
		{
			var file:FileReference = FileReference(event.currentTarget);
			file.removeEventListener(Event.SELECT, file_open_selectHandler);
			file.removeEventListener(Event.CANCEL, file_open_cancelHandler);
		}
		
		override protected function documentReady( _document:DocumentVO ):void 
		{
			_nextEvent.newValue = _document;
			dispatch( _nextEvent );
		}
		
		override protected function bitmapReady( bitmap:Bitmap ):void
		{
			var asset:AssetVO = _items[0] as AssetVO;
			var clone:AssetVO;
			if( asset is CubeTextureVO )
			{
				clone = CubeTextureVO(asset).clone();
				clone[_property] = bitmap.bitmapData;
				dispatch( new SceneEvent( SceneEvent.CHANGE_CUBE_TEXTURE, _items, clone ) );
			}
			else if( asset is TextureVO )
			{
				clone = TextureVO(asset).clone();
				TextureVO(clone).bitmapData = bitmap.bitmapData;
				dispatch( new SceneEvent( SceneEvent.CHANGE_TEXTURE, _items, clone ) );
			}
			
			CursorManager.removeBusyCursor();
		}
		
	}
}