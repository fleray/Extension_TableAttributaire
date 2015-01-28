package com.esrifrance.arcopole.attributetable.client.attributetable
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.layers.supportClasses.Field;
	import com.esri.ags.layers.supportClasses.LayerDetails;
	import com.esrifrance.arcopole.components.selectionmenu.events.SelectionMenuEvent;
	import com.esrifrance.fxfmk.components.ComponentInitializerHelper;
	import com.esrifrance.fxfmk.components.assistedQuery.event.AssistedQueryEvent;
	import com.esrifrance.fxfmk.components.attributeForm.event.AttributeFormEvent;
	import com.esrifrance.fxfmk.components.attributetable.attributetable.AttributeTableEvent;
	import com.esrifrance.fxfmk.components.attributetable.attributetable.AttributeTableView;
	import com.esrifrance.fxfmk.components.attributetable.attributetable.layerlazyloader.LayerLazyLoader;
	import com.esrifrance.fxfmk.components.attributetable.attributetable.selectablegraphic.SelectableGrahic;
	import com.esrifrance.fxfmk.kernel.data.layers.AGSRestLayerRef;
	import com.esrifrance.fxfmk.kernel.data.layers.AGSRestTableRef;
	import com.esrifrance.fxfmk.kernel.data.layers.FxFmkAGSRestTableRefWithEditSupport;
	import com.esrifrance.fxfmk.kernel.data.layers.LayerRef;
	import com.esrifrance.fxfmk.kernel.data.layers.datasource.IDataSource;
	import com.esrifrance.fxfmk.kernel.data.layers.datasource.IDataSourceLayer;
	import com.esrifrance.fxfmk.kernel.data.rightmanagement.RightNames;
	import com.esrifrance.fxfmk.kernel.event.SelectionEvent;
	import com.esrifrance.fxfmk.kernel.service.IAuthorizedMapData;
	import com.esrifrance.fxfmk.kernel.service.IComponentEventBus;
	import com.esrifrance.fxfmk.kernel.service.IConfigManager;
	import com.esrifrance.fxfmk.kernel.service.IDataTools;
	import com.esrifrance.fxfmk.kernel.service.ISelectionManager;
	import com.esrifrance.fxfmk.kernel.tools.GeometryTools;
	import com.esrifrance.fxfmk.kernel.tools.Hashtable;
	import com.esrifrance.fxfmk.kernel.tools.LoggingUtil;
	import com.esrifrance.fxfmk.kernel.tools.SelectionTools;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.ItemClickEvent;
	import mx.logging.ILogger;
	import mx.rpc.AsyncResponder;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.RadioButtonGroup;
	import spark.components.gridClasses.GridColumn;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.GridEvent;

	public class AttributeTableView extends SkinnableComponent
	{
		
		
		private static var _log:ILogger = LoggingUtil.getDefaultLogger(AttributeTableView);
		
		
		/// Injection des services
		
		private const _compInitializer : ComponentInitializerHelper = new ComponentInitializerHelper(this as EventDispatcher, initComponent);
		
		[Inject] public var selectionManager:ISelectionManager;
		[Inject] public var mapData:IAuthorizedMapData;
		[Inject] public var configMgr:IConfigManager;
		[Inject] public var componentEventBus:IComponentEventBus;
		[Inject]public var authorizedMapData:IAuthorizedMapData;
		
		[Inject] public var dataTools:IDataTools;
		[Inject] public var map:Map;
		
		private static var accents:Hashtable = new Hashtable();
		
		public override function initialize():void
		{
			super.initialize();
			_compInitializer.watchInitialization();
		}
		
		
		//// Initialisation
		
		public function AttributeTableView()
		{
			super();
			percentHeight = 100;
			percentWidth = 100;
			this.setStyle("skinClass", AttributeTableViewSkin);
			
			// F.LERAY : pour la conversion des accents en html
			accents.addItem("â", "&acirc;");
			accents.addItem("à", "&agrave;");
			accents.addItem("é", "&eacute;");
			accents.addItem("ê", "&ecirc;");
			accents.addItem("è", "&egrave;");
			accents.addItem("ë", "&euml;");
			accents.addItem("î", "&icirc;");
			accents.addItem("ï", "&iuml;");
			accents.addItem("ô", "&ocirc;");
			accents.addItem("œ", "&oelig;");
			accents.addItem("û", "&ucirc;");
			accents.addItem("ù", "&ugrave;");
			accents.addItem("ü", "&uuml;");
			accents.addItem("ç", "&ccedil;");
			accents.addItem("À", "&Agrave;");
			accents.addItem("Á", "&Aacute;");
			accents.addItem("Â", "&Atilde;");
			accents.addItem("Ã", "&Auml;");
			accents.addItem("Ä", "&Aring;");
			accents.addItem("Å", "&ccedil;");
			accents.addItem("Æ", "&AElig;");
			accents.addItem("Ç", "&Ccedil;");
			accents.addItem("È", "&Egrave;");
			accents.addItem("É", "&Eacute;");
			accents.addItem("É", "&Eacute;");
			accents.addItem("Ê", "&Ecirc;");
			accents.addItem("Ë", "&Euml;");
			accents.addItem("Ì", "&Igrave;");
			accents.addItem("Í", "&Iacute;");
			accents.addItem("Î", "&Icirc;");
			accents.addItem("Ï", "&Iuml;");
			accents.addItem("Ò", "&Ograve;");
			accents.addItem("Ó", "&Oacute;");
			accents.addItem("Ô", "&Ocirc;");
			accents.addItem("Õ", "&Otilde;");
			accents.addItem("Ö", "&Ouml;");
			accents.addItem("Ù", "&Ugrave;");
			accents.addItem("Ú", "&Uacute;");
			accents.addItem("Û", "&Ucirc;");
			accents.addItem("Ü", "&Uuml;");
		}

		
		//// properties
		
		[Bindable]public var layerChoiceDP:ArrayCollection = new ArrayCollection();
		
		[Bindable]public var tmpLayer:LayerRef;
		
		private function initComponent():void
		{
			_log.debug("All services injected, init component");
			
			
			for each (var l:LayerRef in selectionManager.selectableLayers){
				layerChoiceDP.addItem(l);
			}
			
			selectionManager.addSelectionChangeListener(handleSelectionChange);
			
			if(tmpLayer != null && !(tmpLayer is FxFmkAGSRestTableRefWithEditSupport)) loadValuesForLayer(tmpLayer);
			
		}
		
		[Bindable] public var currentLayerRef:LayerRef;
		
		
		
		[Bindable]public var totalFeatureCount:Number = 0;
		
		private var _currentLayerLazyLoader:LayerLazyLoader;
		
		public function loadValuesForLayer(lref:LayerRef):void {
			
			this.currentLayerRef = lref;
			
			var selectionFeatureSet:FeatureSet = selectionManager.getSelection(lref as AGSRestLayerRef);
			
			var layerDetails:LayerDetails = dataTools.getLayerDetails(lref as AGSRestLayerRef);
			// = layerDetails.fields;
			
			var dataSource:IDataSource = mapData.createDataSource(lref);
						
			_currentLayerLazyLoader = new LayerLazyLoader();
			
			
			_currentLayerLazyLoader.initLazyLoader(lref,this.mapData, this.dataTools, new AsyncResponder(
				
				function(objectIds:Array, token:Object=null):void{
					totalFeatureCount = objectIds.length;
					
					
					if(_currentLayerLazyLoader.hasNext()){
						
						_currentLayerLazyLoader.next(new AsyncResponder(
							function(featureSet:FeatureSet, token:Object=null):void{
								
								attributeTable.fields = featureSet.fields;
								
								
								// performance tip : create a new source is more efficient than removeall, and no leak
								// attributeTable.selectableGraphics.removeAll();
								attributeTable.selectableGraphics.source = [];
								
								addAllFeaturesInTable(featureSet.features);
								
							},
							function(fault:Object, token:Object=null):void{
								
							}
						));
						
					}
						
					
					
				},
				function(fault:Object, token:Object=null):void{
					
				}
			));
		}
		
		
		
		private function attributeTableVScrollerReachBottom(e:AttributeTableEvent):void {
			
			var selectionFeatureSet:FeatureSet = selectionManager.getSelection( currentLayerRef as AGSRestLayerRef);
			
			
			var layerDetails:LayerDetails = dataTools.getLayerDetails(currentLayerRef as AGSRestLayerRef);
			
			
			if(_currentLayerLazyLoader.hasNext()){
				
				_currentLayerLazyLoader.next(new AsyncResponder(
					function(featureSet:FeatureSet, token:Object=null):void{
						
						
						addAllFeaturesInTable(featureSet.features);
						
						
						
					},
					function(fault:Object, token:Object=null):void{
						
					}
				));
				
			}
		}
		
		private var _loadingAll:Boolean = false;
		private function loadAllDataClickHandler(e:MouseEvent=null):void {
			
			if(_loadingAll)
				return;
			
			_tempFeatures = [];
			
			_loadingAll = true;
			loadAllDataR();
		}
		
		private function loadAllDataR():void {
			if(_currentLayerLazyLoader == null)
			{
				return;
			}
			if(_currentLayerLazyLoader.hasNext()){
				_log.debug("Still loading");
				_currentLayerLazyLoader.next(new AsyncResponder(
					function(featureSet:FeatureSet, token:Object=null):void{
						
						_tempFeatures = _tempFeatures.concat(featureSet.features);
						
						loadAllDataR();
						
					},
					function(fault:Object, token:Object=null):void{
						
					}
				));
				
			} else {
				_log.debug("All data loaded !");
				_loadingAll = false;
				addAllFeaturesInTable(_tempFeatures);
			}
		}
		
		
		private var _tempFeatures:Array;
		
		private function addAllFeaturesInTable(features:Array):void{
			
			
			_log.debug("Try to load " + features.length + " new feature");
			
			var layerDetails:LayerDetails = dataTools.getLayerDetails(currentLayerRef as AGSRestLayerRef);
			
			
			var selectionFeatureSet:FeatureSet = selectionManager.getSelection( currentLayerRef as AGSRestLayerRef);
			var selectedIds:Array = [];
			
			for each (var selectedGraphic:Graphic in selectionFeatureSet.features){
				selectedIds.push(selectedGraphic.attributes[layerDetails.objectIdField]);
			}
			
			
			var objectIdFieldName:String = layerDetails.objectIdField;
			
			
			var selectableGraphics:Array = [];//attributeTable.selectableGraphics.toArray();
			
			for each (var g:Graphic in features){
				
				var selectableGraphic:SelectableGrahic = new SelectableGrahic();
				selectableGraphic.graphic = g;
				
				// ckeck if graphic is selected or not
				var oid:Object = g.attributes[objectIdFieldName];
				selectableGraphic.selected = false;
				for each (var sid:Object in selectedIds){
					if(sid.toString() == oid.toString()){
						selectableGraphic.selected = true;
						break;
					}
				}
				
				
				selectableGraphics.push(selectableGraphic);
			}
			
			
			//attributeTable.selectableGraphics = new ArrayCollection(selectableGraphics);
			attributeTable.selectableGraphics.addAll(new ArrayCollection(selectableGraphics));
			
		
		}
		
		
		
		////////////////////////////////////////////////////////////
		///
		///			Selection Or All 
		///
		private function selectionOrAllChangeHandler(e:ItemClickEvent):void {
			if(e.currentTarget.selectedValue == "all"){
				attributeTable.showOnlySelected = false;
			}else{
				attributeTable.showOnlySelected = true;
			}
		}
		
		
		private function handleSelectionChange(e:SelectionEvent):void{
			
			var clref:LayerRef=currentLayerRef;
			var layerDetails:LayerDetails = dataTools.getLayerDetails(clref as AGSRestLayerRef);
			if(clref != null && clref is AGSRestLayerRef){
				var selectionFeatureSet:FeatureSet = selectionManager.getSelection(clref as AGSRestLayerRef);
				
				var selectedIds:Array = [];
				for each (var selectedGraphic:Graphic in selectionFeatureSet.features){
					selectedIds.push(selectedGraphic.attributes[layerDetails.objectIdField]);
				}
				
				var objectIdFieldName:String = layerDetails.objectIdField;
				for each (var sg:SelectableGrahic in attributeTable.selectableGraphics.source){
					var searchedID:String = sg.graphic.attributes[objectIdFieldName];
					sg.selected = false;
					for each (var id:String in selectedIds){
						if( searchedID == id){
							sg.selected = true;
							break;
						}
						
					}		
				}
				
				attributeTable.selectableGraphics.refresh();
				attributeTable.validateNow();
			}
		}
		
		
		
		private function attributeTableEventSelectionChangeHandler(e:AttributeTableEvent):void {
			var selectableGraphic:SelectableGrahic = e.selectableGraphic;
			if(selectableGraphic.selected){
				_log.debug("attributeTableEventSelectionChangeHandler : select graphic " + selectableGraphic.graphic);
				selectionManager.addToSelection(currentLayerRef as AGSRestLayerRef, [selectableGraphic.graphic]);
			}else {
				_log.debug("attributeTableEventSelectionChangeHandler : unselect graphic " + selectableGraphic.graphic);
				selectionManager.removeFromSelection(currentLayerRef as AGSRestLayerRef, [selectableGraphic.graphic]);
			}
			
			// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			// F.Leray 22/12/2014
			// START Fix. to force the columns recomputation (to display the ResultsView list) 

			// Show results - dispatch event ASSISTED_QUERY_RESULTS with results
			// (Take displayfield)
			var ld:LayerDetails = dataTools.getLayerDetails(currentLayerRef as AGSRestLayerRef);
			
			// Check if display field appears in results (if not -> display field not authorized for user)		
			var field:String = null;
			
			if (ld.displayField != null)
			{
				for (var fldName:String in selectableGraphic.graphic.attributes)
				{
					if (fldName.toLowerCase() == ld.displayField.toLowerCase())
					{
						field = ld.displayField;
						break;
					}
				}
			}
			
			if (field == null)
			{
				for each  (var f:Field in ld.fields)
				{
					if (f.type == Field.TYPE_OID)
					{
						field = f.name;
						break;
					}
				}
				// Display field not found in results
				_log.info("DisplayField not found, use object id");
			}
			
			// F.Leray 22/12/2014
			// END Fix. to force the columns recomputation (to display the ResultsView list)
			// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			
			this.componentEventBus.dispatchEvent(
				new AssistedQueryEvent(AssistedQueryEvent.ASSISTED_QUERY_RESULTS, currentLayerRef as AGSRestTableRef, new Array(), [field], true));		
			
			/*this.componentEventBus.dispatchEvent(
				new SelectionMenuEvent(SelectionMenuEvent.SHOW_SELECTION_OR_RESULTS, SelectionMenuEvent.RESULTS_UI));*/
			
		}
		
		////////////////////////////////////////////////////////////
		///
		///			Zoom to All 
		///
		public function zoomToAllSelectedFeatureClickHandler(e:MouseEvent) : void 
		{
			if (this.attributeTable.selectableGraphics == null || this.attributeTable.selectableGraphics.length == 0)
				return;
			
			SelectionTools.zoomToSelection(this.map, currentLayerRef as AGSRestLayerRef, this.selectionManager);
		}
		
		
		////////////////////////////////////////////////////////////
		///
		///			Export in Excel
		///
		
		
		
		public function exportToExcelClickHandler(e:MouseEvent) : void
		{
			
			_log.debug("Exporting to Excel");
			// verification des droits de l'utilisateur
			var layerRef:AGSRestLayerRef = tmpLayer as AGSRestLayerRef;
			var l:Layer =  authorizedMapData.getMapServiceById(layerRef.mapservice.id);
			
			if (l !=null){
				var r:String = authorizedMapData.getRightForMapServiceLayer(l, RightNames.EXPORT, "false");
			}
			
			
			if (r!="true") 
			{
				_log.debug("Failed to export => No Right to export");
				Alert.show("Vous n'avez pas le droit d'exporter la couche...", "Export de données :");
				return;
			}
			_log.debug("Ok to export data");
			
			//Prepare request
			var url:String = configMgr.applicationURL + "/exportexcel";
			
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			request.data = new URLVariables();				
			request.data.html = getHTMLTable(this.attributeTable.attributeTableDataGrid);
			//Open window
			navigateToURL(request);				
		}
		
		private function getHTMLTable(dg:DataGrid) : String
		{
			var str:String = "<html><body><table><thead><tr>";
			// Field names
			for each (var header:GridColumn in dg.columns) {
				if(header.visible)
					str += "<td>" + header.headerText + "</td>";
			}
			str += "</tr></thead><tbody>";
			// Field values
			for each (var item:Object in dg.dataProvider) {
				str += "<tr>";
				for each (var column:GridColumn in this.attributeTable.attributeTableDataGrid.columns) {
					if(column.visible)
					{			
						str += "<td>" + stringReplaceAccents(column.itemToLabel(item)) + "</td>";
					}
				}
				str += "</tr>";
			}
			str += "</tbody></table></body></html>";
			return str;
		}
		
		private static function stringReplaceAccents( source:String ) : String
		{
			
			if(null != source)
			{
				for each(var accent:String in accents.getAllKeys())
				{
					source =stringReplaceAll(source, accent, accents.getItem(accent));
				}
			}
			
			return source;
		}
		
		private static function stringReplaceAll( source:String, find:String, replacement:String ) : String
		{
			return source.split( find ).join( replacement );
		}
		
		////////////////////////////////////////////////////////////
		///
		///		On over / On out / doubleclick
		///
		
		protected function resultLisDoubleClick(ev:GridEvent) : void
		{
			
			if(ev.item == null )
				return;
			
			var graphic:Graphic = (ev.item as SelectableGrahic).graphic
			
			_log.debug("Show attribute Form for graphic " + graphic);
				
			componentEventBus.dispatchEvent(new AttributeFormEvent(
				AttributeFormEvent.ATTRIBUTE_FORM_SHOW, currentLayerRef as AGSRestLayerRef, null, graphic));			
			
			// Zoom to selected item
			//SelectionTools.shiftObjectOnTheLeft(graphic, map);
			GeometryTools.zoomTo(map,graphic.geometry);
		}
		
		
		protected function resultListItemRollOver(ev:GridEvent) : void 
		{	
			if(ev.item == null || selectionOrAll.selectedValue == "all")
				return;
			SelectionTools.applyOverGraphic((ev.item as SelectableGrahic).graphic);
			
		}
	
		protected function resultListItemRollOut(ev:GridEvent) : void 
		{
			if(ev.item == null || selectionOrAll.selectedValue == "all")
				return;
			SelectionTools.applyOutGraphic((ev.item as SelectableGrahic).graphic, selectionManager);
		}
		
		
		////////////////////////////////////////////////////////////
		///
		///			LayerDropDownList 
		///
		
		
		////////////////////////////////////////////////////////////
		///
		///			PartAdded / PartRemoved
		///
		
		[SkinPart(required="true")] public var attributeTable:com.esrifrance.fxfmk.components.attributetable.attributetable.AttributeTableView;
		[SkinPart(required="true")] public var selectionOrAll:RadioButtonGroup;
		[SkinPart(required="false")] public var loadAllData:Button;
		[SkinPart(required="false")] public var zoomToAllSelectedFeature:Button;
		[SkinPart(required="false")] public var exportToExcel:Button;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if( selectionOrAll == instance){
				selectionOrAll.addEventListener(ItemClickEvent.ITEM_CLICK, selectionOrAllChangeHandler);
			} else if(attributeTable == instance){
				attributeTable.addEventListener(AttributeTableEvent.SELECTION_CHANGE, attributeTableEventSelectionChangeHandler);
				attributeTable.addEventListener(AttributeTableEvent.VERTICAL_SCROLLBAR_REACH_BOTTOM, attributeTableVScrollerReachBottom);
				attributeTable.attributeTableDataGrid.doubleClickEnabled = true;
				attributeTable.attributeTableDataGrid.addEventListener(GridEvent.GRID_ROLL_OVER, resultListItemRollOver);
				attributeTable.attributeTableDataGrid.addEventListener(GridEvent.GRID_ROLL_OUT, resultListItemRollOut);
				attributeTable.attributeTableDataGrid.addEventListener(GridEvent.GRID_DOUBLE_CLICK, resultLisDoubleClick);
			} else if(loadAllData == instance){
				loadAllData.addEventListener(MouseEvent.CLICK, loadAllDataClickHandler);
			} else if(zoomToAllSelectedFeature == instance){
				zoomToAllSelectedFeature.addEventListener(MouseEvent.CLICK, zoomToAllSelectedFeatureClickHandler);
			} else if(zoomToAllSelectedFeature == instance){
				zoomToAllSelectedFeature.addEventListener(MouseEvent.CLICK, zoomToAllSelectedFeatureClickHandler);
			} else if(exportToExcel == instance){
				exportToExcel.addEventListener(MouseEvent.CLICK, exportToExcelClickHandler);
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			if( selectionOrAll == instance){
				selectionOrAll.removeEventListener(ItemClickEvent.ITEM_CLICK, selectionOrAllChangeHandler);
			} else if(attributeTable == instance){
				attributeTable.removeEventListener(AttributeTableEvent.SELECTION_CHANGE, attributeTableEventSelectionChangeHandler);
				attributeTable.removeEventListener(AttributeTableEvent.VERTICAL_SCROLLBAR_REACH_BOTTOM, attributeTableVScrollerReachBottom);
				attributeTable.attributeTableDataGrid.removeEventListener(GridEvent.GRID_ROLL_OVER, resultListItemRollOver);
				attributeTable.attributeTableDataGrid.removeEventListener(GridEvent.GRID_ROLL_OUT, resultListItemRollOut);
				attributeTable.attributeTableDataGrid.removeEventListener(GridEvent.GRID_DOUBLE_CLICK, resultLisDoubleClick);
			} else if(loadAllData == instance){
				loadAllData.removeEventListener(MouseEvent.CLICK, loadAllDataClickHandler);
			} else if(zoomToAllSelectedFeature == instance){
				zoomToAllSelectedFeature.removeEventListener(MouseEvent.CLICK, zoomToAllSelectedFeatureClickHandler);
			} else if(exportToExcel == instance){
				exportToExcel.removeEventListener(MouseEvent.CLICK, exportToExcelClickHandler);
			}
		}
		
	}
}