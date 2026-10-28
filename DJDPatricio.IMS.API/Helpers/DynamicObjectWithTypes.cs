using System.Reflection;

namespace DJDPatricio.IMS.API.Helpers;

public class DynamicObjectWithTypes
{
    public Dictionary<string, object> Properties = new();
    public void AddProperty<T>(string propertyName, T value)
    {
        Properties[propertyName] = value!;
    }
    public void AddClassPropertiesToDynamicObject<T>(T obj, DynamicObjectWithTypes dynamicObject)
    {
        var properties = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);

        foreach (var prop in properties)
        {
            var value = prop.GetValue(obj);
            dynamicObject.AddProperty(prop.Name, value);
        }
    }
}


