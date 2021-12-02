%%%
title = "Game State over Real Time Protocol"
abbrev = "Game State over RTP"
ipr= "trust200902"
area = "applications"
workgroup = ""
keyword = ["realtime","game"]

[seriesInfo]
status = "informational"
name = "Internet-Draft"
value = "draft-jennings-game-state-over-rtp-00"
stream = "IETF"

[[author]]
initials="C."
surname="Jennings"
fullname="Cullen Jennings"
organization = "cisco"
  [author.address]
  email = "fluffy@iii.ca"
%%%

.# Abstract

This specification defines an RTP payload to send game moves and objects
over RTP. This is useful for games as well collaboration systems that
use augment or virtual reality.

{mainmatter}

# Overview

Many real time applications, such as games, want to to share state
about 3D objects across the network. This specification allows an
application to define objects with state, and the current values of that
state over RTP.

The conceptual model is each RTP sender has a small number of objects
with state that need to be synchronized ot the other side. The current
values are periodically sent over RTP.  The MAY be sent when the values
change but they MUST also be periodically sent so that any lost updates
are send again and the state is eventually consistent.

The state sent can include a time stamp and rate changes estimates that
allow the receiver to estimate the current state values even at a point
in the future. An application that receives a state update can apply it
immediate (often called immediate based), wait a fixed delay for then
apply it (often called delay based), or apply a predicted value based on
overwriting any previous predictions (often called rollback based).

In many cases the state does not have any units but if does, SI units
SHOULD be used. Unless otherwise defined by the application, the default
coordinate system SHOULD be a left handed coordinate system where Y
points up and X points to the right.

Applications can define there own objects or use some of the predefined
common objects. Each object is identified by a type and identifier number
to uniquely identify the object within the scope of that senders RTP
stream. Multipel updates and objects can be combined in a single RTP
packet so that they are guaranteed to be fate shared and either atomically
delivered at the same time or not delivered at all to the receiver.

The objects are defined as a series of primitives that define common
types. The objects and updates to state are encoded with Tag Length
Value (TLV) style encoding so that receivers cna skip objects they do
not understand. The Objects in an single RTP packet MUST be processed in
order. This allows a sender to write state in an old and new format at
the new format to override values in the old format in a single RTP
packet. This allows for an easy upgrade from old to new ways or
representing state with backwards compatibility.

# Goals:

* Support 2D and 3D
* Support delay and rollback based synchronization
* Relatively compact but simple encoding
* Extensible for applications to send their own custom data
* Support for forward and backwards compatibility 


# Primitives

This section defined so primitives that are useful in defining objects.

## Location

```
Loc1 := x,y,z:Float32;
```

Loc1 is simply a 3D location of a point stored in Float 32;

```
Loc2 := x,y,z:Float32; vx,vy,vz:Float16;
```
Loc2 has a location as well as the rate of change per second.

## Normal

```
Norm1 := nx,ny,nz:Float16;
``
Normal vector for a point. 

## TextureUV

```
TextureUV1 := u,v:VarInt;
``
Normal vector for a point.

## Rotation

```
Rot1 := i,j,k:Float16;
```

The non real parts of a normalized rotation quaternion.

```
Rot2 := s:Rot1, e:Rot1;
```

Rot2 defines the s, the current rotation, and e, an estimated value of
the rotation in one second. This allows the receiver to use an algorithm
such as SLERP to estimate the current rotation.


## Child Transform

```
Transform1 := tx,ty,tz:Float16;
```

Defines a linear translation of a child object from a base object.

## Texture

```
TextureUrl1 := String;
```

URL of image with texture map. JPEG SHOULD be supported.


## Texture Stream

```
TextureUrl2 := pt: UInt8;
```

RTP "Payload Type" value of RTP video stream to use as a texture map.

## Timestamp 

Time1 := timeMs: Int16 ; 

Bottom 16 bits of NTP time in ms since unix epoch;

# Objects

All objects must start with a tag a VarInt length then VarInt objectID.
Applications can reserver tags for their objects in the registry defined
in the IANA section.


## Common Objects

### Player Head

```
Head1 := head1:Tag,  len:VarInt, objectID:VarInt,   time:Time1,
   loc:Loc2, rot:Rot2, [ headIPD1:Tag, ipd:Float16 ]
```

Defines location and rotate of head with options inter pupil distance. 

### Mesh 

Object with the following 

```
Mesh1 := mesh1:Tag,  len:VarInt, objectID:VarInt, 
    vertexes: Loc1[], 
    normals: Norm1[], 
    uv:  TextureUV1, 
    triangles: Int16[3][];
```

The vertex is an array of at least 3 locations that defines the vertex
of a triangle mesh. The normals array but either be empty or the same
size as the vertex and define the normal for each vertex. The uv array
must be empty or same size as vertex array and have the u,v coordinate
in the texture map for the vertex.

The triangles array can be of a different size fro the Vertexs array.
Each entry defines one triangle in the mest and contains the index of
the three vertex in the vertexes array. Vertexes MUST be in counter
clockwise order.


### Player Hand

```
Hand1 := hand1:Tag,  len: int16, objectID:VarInt,  time:Time1, left:Bool,
   loc:Loc2, rot:Rot2
```

The Hand1 identifiers a location and rotation of a hand. The left is
true for the left hand false for a right hand.

```
Hand2 := hand2:Tag,  len: int16, objectID:VarInt,  time:time1,
  left:Bool,
  loc:Loc2, rot:Rot2, 
  pinkyTip, pinkyDistal, pinkyIntermediate, pinkyProximal,pinkinMetaCarpal:Transform1 
  ringTip,ringDistal,ringIntermediate,ringProximal,ringMetacarpal:Transform1 
  middleTip,middleDistal,middleIntermediate,middleProximal,middleMetacarpal:Transform1 
  indexTip,indexDistal,indexIntermediate,indexProximal,indexMetacarpal:Transform1 
  thumbTip,thumbDistal,thumbProximal,thumbMetacarpal:Transform1 
  wrist: Transform1
  ```

Hand2 represes a wired skeletal hand. Names of the joints are explained
at [https://en.wikipedia.org/wiki/Interphalangeal_joints_of_the_hand]

This is about 175 bytes @ 5Hz = 7 kbps 



# Encoding

In general, little endian encoding is used on the wire to reduce byte
swaps on common hardware.

## Tag

Tag := VarInt;

Constant values of tags can be found in the IANA section.


## Float

Float16, Float32, and Float64 are encoded as IEEE 754 half, single, and
double precisions respectively.

## Boolean

Encoded as byte with 0 or 1 for false or true; 

## Integer

UInt8, Int8, UInt16, Int16, UInt32, Int32, UInt16, Int64 encoded as
1,2,4, or 8 bytes.

VarInt are encoded as:
* Top bits of first byte is 0, then  7 bit signed integer (-64 to 63)
* Top bits of first byte is 10, then  6+8 bit signed integer  ( -8192 to 8191 ) 
* Top bits of first byte is 110, then  5+16 bit signed integer ( 1,048,576 to 1,048,575 ) 
* Top bits of first byte is 1110,0000 then next 4 bytes 32 bit integer 
* Top bits of first byte is 1110,0001 then next 4 bytes 32 bit signed integer 
* Top bits of first byte is 1110,0010 then next 8 bytes 64 bit integer 
* Top bits of first byte is 1110,0011 then next 8 bytes 64 bit signed integer 


## String

Strings are encoded as a VarInt length in bytes (not characters)
followed by a UTF-8 version of the string.

## Blob 

Blobs are encoded as a VarInt length in bytes followed
by the binary data. 

## Arrays 

Variable length arrays are encoded with the number of elements in the
array encoded as a VarInt followed by the values in the array. Fixed
length array do not have the number of elements at start of encoding.


# IANA

# RTP

This section can be split out a separate payload draft we need some
extra work.

The media type is application/gamestate. The are no optional or required
parameters. The RTP marker bit is not used. The RTP clock MUST be 90 kHz.

Multiple Objects as defined in this specification can be concatenated
into one RTP payload.

## Game State Tag Registry

The specification defines a new IANA registry for tag values. All values
MUST be greater than zero. Values 1-63 are defined with a standards track
specification. Values 63-8191 are assigned by expert review. Values 8192
to 1,048,575 are FCFS.

Initial assignments are:
* head1: 1
* hand1: 2 
* mesh1: 64
* hand2: 65
* headIPD1: 66

# Security

Like most things in RTP, the data in can be personal identifying
information. For example, the Hand2 type of data when generated by
tracking a persons hand might identify that user.

{backmatter}

# Acknowledgments

Thanks to ....

# Test Vectors

## Head Location

Head Location type 1 with head at location 1.1,0.2,30, no rotation, an
objectID of 4, a time of 5 ms and an IPD of 0.056.

TODO
