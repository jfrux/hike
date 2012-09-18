component name="ArrayComponent" {
	public any function init() {
		this['arr'] = [];
		this['utils'] = createObject("java","org.apache.commons.lang.ArrayUtils");

		return this;
	}

	public any function length() {
		return arrayLen(this.__arr__);
	}

	public any function slice() {
		var argCount = listLen(structKeyList(arguments));
		
		return this.__arr__.subList();
	}

	
}