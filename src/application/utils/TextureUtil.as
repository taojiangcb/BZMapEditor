﻿package application.utils
{
	import flash.geom.Rectangle;
	
	/**
	 * For place texture
	 */
	public final class TextureUtil
	{
		private static const HIGHEST:uint = 0xFFFFFFFF;
		
		/**
		 * Place textures by textureAtlasXML data
		 */
		public static function packTextures(widthDefault:uint, padding:uint, rectMap:Object, verticalSide:Boolean = false):Rectangle
		{
			for each(var rect:Rectangle in rectMap)
			{
				break;
			}
			if(!rect)
			{
				return null;
			}
			
			/*纹理总面积*/
			var dimensions:uint = 0;
			var rectList:Vector.<Rectangle> = new Vector.<Rectangle>;
			var maxHeight:int = 0;
			var maxWidth:int = 0;
			for each(rect in rectMap)
			{
				dimensions += rect.width * rect.height;
				rectList.push(rect);
				if(maxWidth < rect.width){
					maxWidth = rect.width;
				}
				if(maxHeight < rect.height){
					maxHeight = rect.height;
				}
			}
			//sort texture by size
			rectList.sort(sortRectList);
			
			if(widthDefault == 0)
			{
				//calculate width for Auto size
				widthDefault = Math.sqrt(dimensions);
			}
			
			widthDefault = getNearest2N(Math.max(int(rectList[0].width) + padding, widthDefault));
			if(widthDefault < maxHeight){
				widthDefault *= 2;
			}
			if(widthDefault < maxWidth){
				widthDefault *= 2;
			}
			
			var heightMax:uint = HIGHEST;
			var remainAreaList:Vector.<Rectangle> = new Vector.<Rectangle>;
			remainAreaList.push(new Rectangle(0, 0, widthDefault, heightMax));
			
			var isFit:Boolean;
			var width:int;
			var height:int;
			
			var area:Rectangle;
			var areaPrev:Rectangle;
			var areaNext:Rectangle;
			var areaID:int;
			var rectID:int;
			do 
			{
				//Find highest blank area
				area = getHighestArea(remainAreaList);
				areaID = remainAreaList.indexOf(area);
				isFit = false;
				rectID = 0;
				for each(rect in rectList) 
				{
					//check if the area is fit
					width = int(rect.width) + padding;
					height = int(rect.height) + padding;
					if (area.width >= width && area.height >= height) 
					{
						//place portrait texture
						if(
							verticalSide?
							(
								height > width * 4?
								(
									areaID > 0?
									(area.height - height >= remainAreaList[areaID - 1].height):
									true
								):
								true
							):
							true
						)
						{
							isFit = true;
							break;
						}
					}
					rectID ++;
				}
				
				if(isFit)
				{
					//place texture if size is fit
					rect.x = area.x;
					rect.y = area.y;
					rectList.splice(rectID, 1);
					remainAreaList.splice(
						areaID + 1,
						0, 
						new Rectangle(area.x + width, area.y, area.width - width, area.height)
					);
					area.y += height;
					area.width = width;
					area.height -= height;
				}
				else
				{
					//not fit, don't place it, merge blank area to others toghther
					if(areaID == 0)
					{
						areaNext = remainAreaList[areaID + 1];
					}
					else if(areaID == remainAreaList.length - 1)
					{
						areaNext = remainAreaList[areaID - 1];
					}
					else
					{
						areaPrev = remainAreaList[areaID - 1];
						areaNext = remainAreaList[areaID + 1];
						areaNext = areaPrev.height <= areaNext.height?areaNext:areaPrev;
					}
					if(area.x < areaNext.x)
					{
						areaNext.x = area.x;
					}
					areaNext.width = area.width + areaNext.width;
					remainAreaList.splice(areaID, 1);
				}
			}
			while (rectList.length > 0);
			
			heightMax = getNearest2N(heightMax - getLowestArea(remainAreaList).height);
			
			return new Rectangle(0, 0, widthDefault, heightMax);
		}
		
		private static function sortRectList(rect1:Rectangle, rect2:Rectangle):int
		{
			var v1:uint = rect1.width + rect1.height;
			var v2:uint = rect2.width + rect2.height;
			if (v1 == v2) 
			{
				return rect1.width > rect2.width?-1:1;
			}
			return v1 > v2?-1:1;
		}
		
		private static function getNearest2N(_n:uint):uint
		{
			return _n & _n - 1?1 << _n.toString(2).length:_n;
		}
		
		private static function getHighestArea(areaList:Vector.<Rectangle>):Rectangle
		{
			var height:uint = 0;
			var areaHighest:Rectangle;
			for each(var area:Rectangle in areaList) 
			{
				if (area.height > height) 
				{
					height = area.height;
					areaHighest = area;
				}
			}
			return areaHighest;
		}
		
		private static function getLowestArea(areaList:Vector.<Rectangle>):Rectangle
		{
			var height:uint = HIGHEST;
			var areaLowest:Rectangle;
			for each(var area:Rectangle in areaList) 
			{
				if (area.height < height) 
				{
					height = area.height;
					areaLowest = area;
				}
			}
			return areaLowest;
		}
	}
}