uniform float uTime;
uniform sampler2D uMatcap;
uniform vec2 mouse;
uniform float progress;
varying vec2 vUv;

vec2 getMatcap(vec3 eye,vec3 normal){
    vec3 reflected=reflect(eye,normal);
    float m=2.8284271247461903*sqrt(reflected.z+1.);
    return reflected.xy/m+.5;
}

float sdSphere(vec3 p,float s)
{
    return length(p)-s;
}

float smin(float a,float b,float k)
{
    float h=max(k-abs(a-b),0.)/k;
    return min(a,b)-h*h*k*(1./4.);
}

mat4 rotationMatrix(vec3 axis,float angle){
    axis=normalize(axis);
    float s=sin(angle);
    float c=cos(angle);
    float oc=1.-c;
    
    return mat4(oc*axis.x*axis.x+c,oc*axis.x*axis.y-axis.z*s,oc*axis.z*axis.x+axis.y*s,0.,
        oc*axis.x*axis.y+axis.z*s,oc*axis.y*axis.y+c,oc*axis.y*axis.z-axis.x*s,0.,
        oc*axis.z*axis.x-axis.y*s,oc*axis.y*axis.z+axis.x*s,oc*axis.z*axis.z+c,0.,
    0.,0.,0.,1.);
}

vec3 rotate(vec3 v,vec3 axis,float angle){
    mat4 m=rotationMatrix(axis,angle);
    return(m*vec4(v,1.)).xyz;
}

float sdBox(vec3 p,vec3 b)
{
    vec3 q=abs(p)-b;
    return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}

float sdf(vec3 p){
    vec2 resolution=vec2(2.,1.);
    
    vec3 p1=rotate(p,vec3(1.),uTime/5.);
    float box=smin(sdBox(p1,vec3(.2)),sdSphere(p,.3),.3);
    float realSphere=sdSphere(p1,.3);
    float final=mix(box,realSphere,progress);
    float sphere=sdSphere(p-vec3(mouse*resolution.xy,0.),.2);
    
    return smin(final,sphere,.5);
}

vec3 calcNormal(in vec3 p)// for function f(p)
{
    const float eps=.0001;// or some other value
    const vec2 h=vec2(eps,0);
    return normalize(vec3(sdf(p+h.xyy)-sdf(p-h.xyy),
    sdf(p+h.yxy)-sdf(p-h.yxy),
    sdf(p+h.yyx)-sdf(p-h.yyx)));
}

void main()
// {What is ray marching???????
    float dist=length(vUv-vec2(.5));
    vec3 bg=mix(vec3(0.),vec3(.3),dist);
    vec2 resolution=vec2(2.,1.);
    vec3 camPos=vec3(0.,0.,2.);
    vec3 ray=normalize(vec3((vUv-vec2(.5))*resolution.xy,-1.));
    ////
    vec3 rayPos=camPos;
    float t=0.;
    float tMax=5.;
    
    for(int i=0;i<256;i++){
        vec3 pos=camPos+t*ray;
        float h=sdf(pos);
        if(h<.0001||t>tMax)break;
        t+=h;
    }
    
    vec3 color=bg;
    if(t<tMax){
        vec3 pos=camPos+t*ray;
        
        color=vec3(1.,1.,1.);
        vec3 normal=calcNormal(pos);
        color=normal;
        float diff=dot(vec3(1.),normal);
        vec2 matcapUv=getMatcap(ray,normal);
        color=vec3(diff);
        color=texture2D(uMatcap,matcapUv).rgb;
        float fresnel=pow(1.+dot(ray,normal),3.);
        // color = vec3(fresnel);
    }
    gl_FragColor=vec4(color,1.);
    // gl_FragColor=vec4(vec3(dist), 1.);
}