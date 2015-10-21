using System.Collections;


public delegate void handleDelegate1<P1>(P1 p1);
public delegate void handleDelegate2<P1, P2>(P1 p1, P2 p2);
public delegate void handleDelegate3<P1, P2, P3>(P1 p1, P2 p2, P3 p3);


public class HandlerBase
{
    public void Handle(string msg)
    {

    }
}

public class Handler<P1> : HandlerBase
{
    public void Handle(string msg)
    {

    }
}

public class Handler<P1, P2> : HandlerBase
{





    public void Handle(string msg)
    {

    }
}

public class Handler<P1, P2, P3> : HandlerBase
{
    public handleDelegate3<P1, P2, P3> handle;

    public void Handle(string msg)
    {
        StringByte sb = new StringByte(msg);

        P1 p1 = sb.Read<P1>();
        P2 p2 = sb.Read<P2>();
        P3 p3 = sb.Read<P3>();

        handle(p1, p2, p3);
    }
}

public class HandlerManager
{
    Dictionary<string, HandlerBase> handlers;

    public void Register<P1, P2, P3>(string name, handleDelegate3<P1, P2, P3> handle)
    {
        Handler<P1, P2, P3> handler = new Handler<P1, P2, P3>(handle);
        handlers[name] = handler;
    }

    public void Handle(string name, string msg)
    {
        if (handlers.ComtainKey(name))
            handlers[name].Handle(msg);
    }
}

public class StringByte
{
    StringByte()
    {
    }

    StringByte(string str)
    {
    }

    public string Read<float>()
    {
        int len = content[index];
        ++index;
        string valStr = content.Substring(index, len);
        index += len;
        return float.Parse(valStr);
    }

    public float Read<string>()
    {
        int lenlen = content[index];
        ++index;
        string lenStr = content.Substring(index, lenlen);
        index += lenlen;
        
        int len = float.Parse(lenStr);
        string valStr = content.Substring(index, len);
        index += len;

        return valStr;
    }

    public bool Read<bool>()
    {
        ++index;
        return content[index] == 1 ? true : false;
    }

    public void Write(bool val)
    {

    }

    public void Write(float val)
    {

    }

    public void Write(string val)
    { 
    
    }

    string content;
    int bufferEnd = 0;
}
