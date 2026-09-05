# 附录I 转换为ISO标准C++
您可能想将一些用C或老式C++版本开发的程序转换为标准C++，本附录提供了这方面的一些指南。其中的一些内容是关于从C转换为C++的，另一些是关于从老式C++转换为标准C++的。

## I.1 使用一些预处理器编译指令的替代品
C/C++预处理器提供了一系列的编译指令。通常，C++惯例是使用这些编译指令来管理编译过程，而避免用编译指令替换代码。例如，#include编译指令是管理程序文件的重要组件。其他编译指令（如#ifndef和# endif）使得能够控制是否对特定的代码块进行编译。# pragma编译指令使得能够控制编译器特定的编译选项。这些都是非常有帮助（有时是必不可少）的工具。但使用# define编译指令时应谨慎。

### I.1.1 使用const而不是#define来定义常量
符号常量可提高代码的可读性和可维护性。常量名指出了其含义，如果要修改它的值，只需定义修改一次，然后重新编译即可。C使用预处理器来创建常量的符号名称。
```c++
#define MAX_LENGTH 100
```

这样，预处理器将在编译之前对源代码执行文本置换，即用100替换所有的MAX_LENGTH。

而C++则在变量声明使用限定符const：
```c++
const int MAX_LENGTH = 100;
```

这样MAX_LENGTH将被视为一个只读的int变量。

使用const的方法有很多优越性。首先，声明显式指明了类型。使用 # define时，必须在数字后加上各种后缀来指出除char、int或double之外的类型。例如，使用100L来表明long类型，使用3.14F来表明float类型。更重要的是，const方法可以很方便地用于复合类型，如下例所示：
```c++
const int base_vals[5] = {1000, 2000, 3500, 6000, 10000};
const string ans[3] = {"yes", "no", "maybe"};
```

最后，const标识符遵循变量的作用域规则，因此，可以创建作用域为全局、名称空间或数据块的常量。在特定函数中定义常量时，不必担心其定义会与程序的其他地方使用的全局常量冲突。例如，对于下面的代码：
```c++
#define n 5
const int dz = 12;
...
void fizzle()
{
    int n;
    int dz;
    ...
}
```

预处理器将把：
```c++
int n;
```

替换为：
```c++
int 5;
```

从而导致编译错误。而fizzle( )中定义的dz是本地变量。另外，必要时，fizzle( )可以使用作用域解析运算符（::），以::dz的方式访问该常量。

虽然C++借鉴了C语言中的关键字const，但C++版本更有用。例如，对于外部const值，C++版本有内部链接，而不是变量和C中const所使用的默认外部链接。这意味着使用const的程序中的每个文件都必须定义该const。这好像增加了工作量，但实际上，它使工作更简单。使用内部链接时，可以将const定义放在工程中的各种文件使用的头文件中。对于外部链接，这将导致编译错误，但对于内部链接，情况并非如此。另外，由于const必须在使用它的文件中定义（在该文件使用的头文件中定义也满足这样的要求），因此可以将const值用作数组长度参数：
```c++
const int MAX_LENGTH = 100;
...
double loads[MAX_LENGTH];
for (int i = 0; i < MAX_LENGTH; i++)
    loads[i] = 50;
```

这在C语言中是行不通的，因为定义MAX_LENGTH的声明可能位于一个独立的文件中，在编译时，该文件可能不可用。坦白地说，在C语言中，可以使用static限定符来创建内部链接常量。也就是说，C++通过默认使用static，让您可以少记住一件事。

顺便说一句，修订后的C标准（C99）允许将const用作数组长度，但必须将数组作为一种新式数组——变量数组，而这不是C++标准的一部分。

在控制何时编译头文件方面，# define编译指令仍然很有帮助：
```c++
// blooper.h
#ifndef _BLOOPER_H_
#define _BLOOPER_H_
// code goes here
#endif
```

但对于符号常量，习惯上还是使用const，而不是#define。另一个好方法——尤其是在有一组相关的整型常量时——是使用enum：
```c++
enum {LEVEL1 = 1, LEVEL2 = 2, LEVEL3 = 4, LEVEL4 = 8};
```

### I.1.2 使用inline而不是# define来定义小型函数
在创建类似于内联函数的东西时，传统的C语言方式是使用一个#define宏定义：
```c++
#define Cube(X) X*X*X 
```

这将导致预处理器进行文本置换，将X替换为Cube( )的参数：
```c++
y = Cube(x);        // replaced with y = x*x*x;
y = Cube(x + z++);  // replaced with y = x + z++*x + z++*x + z++;
```

由于预处理器使用文本置换，而不是真正地传递参数，因此使用这种宏可能导致意外的、错误的结果。要避免这种错误，可以在宏中使用大量的圆括号来确保正确的运算顺序：
```c++
#define Cube(X) ((X)*(X)*(X))
```

但即使这样做，也无法处理使用诸如Z++等值的情况。

C++方法是使用关键字inline来标识内联函数，这种方法更可靠，因为它采用的是真正的参数传递。另外，C++内联函数可以是常规函数，也可以是类方法：
```c++
class dormant
{
private:
    int period;
    ...
public:
    int Period() const { return period; } // automatically inline
    ...
};
```

#define宏的一个优点是，它是无类型的，因此将其用于任何类型，运算都是有意义的。在C++中，可以创建内联模板来使函数独立于类型，同时传递参数。

总之，请使用C++内联技术，而不是C语言中的#define宏。

## I.2 使用函数原型
实际上，您没有选择的余地。虽然在C语言中，原型是可选的，但在C++中，它确实是必不可少的。请注意，在使用之前定义的函数（如内联函数）是其原型。

应尽可能在函数原型和函数头中使用const。具体地说，对于表示不可修改的数据的指针参数和引用参数，应使用const。这不仅使编译器能够捕获修改数据的错误，也使函数更为通用。也就是说，接受const指针或引用的函数能够同时处理const数据和非const数据，而不使用const指针或引用的函数只能处理非const数据。

## I.3 使用类型转换
Stroustrup对C语言的抱怨之一是其无规律可循的类型转换运算符。确实，类型转换通常是必需的，但标准类型转换太不严格。例如，对于下面的代码：
```c++
struct Doof
{
    double feeb;
    double steeb;
    char sgif[10];
};
Doof leam;
short * ps = (short *) & leam;    // old syntax
int * pi = int * (&leam);         // new syntax
```

C语言不能防止将一种类型的指针转换为另一种完全不相关的类型的指针。

从某种意义上看，这种情况与goto语句相似。goto语句的问题太灵活了，导致代码混乱。解决方法是提供更严格的、结构化程度更高的goto版本，来处理需要使用goto语句的常见任务，诸如for循环、while循环和if else语句等语言元素应运而生。对于类型转换不严格的问题，标准C++提供了类似的解决方案，即用严格的类型转换来处理最常见的、需要进行类型转换的情况。下面是第15章介绍的类型转换运算符：

* dynamic_cast；
* static_cast；
* const_cast；
* reinterpret_cast。

因此，在执行涉及指针的类型转换时，应尽可能使用上述运算符之一。这样做不但可以指出类型转换的目的，并可以检查类型转换是否是按预期那样使用的。

## I.4 熟悉C++特性
如果使用的是malloc( )和free( )，请改用new和delete；如果是使用setjmp( )和longjmp( )处理错误，则请改用try、throw和catch。另外，对于表示true和false的值，应将其类型声明为bool。

## I.5 使用新的头文件
C++标准指定了头文件的新名称，请参见第2章。如果使用的是老式头文件，则应当改用新名称。这样做不仅仅是形式上的改变，因为新版本有时新增了特性。例如，头文件ostream提供了对宽字符输入和输出的支持，还提供了新的控制符，如boolalpha和fixed（请参见第17章）。对于众多格式化选项的设置来说，这些控制符提供的接口比使用setf( )或iomanip函数更简单。如果确实使用的是setf( )，则在指定常量时，请使用ios_base而不是ios，即使用ios_base::fixed而不是ios::fixed。另外，新的头文件包含名称空间。

## I.6 使用名称空间
名称空间有助于组织程序中使用的标识符，避免名称冲突。由于标准库是使用新的头文件组织实现的，它将名称放在std名称空间中，因此使用这些头文件需要处理名称空间。

出于简化的目的，本书的示例通常使用编译指令using来使std名称空间中的名称可用：
```c++
#include <iostream>
#include <string>
#include <vector>
using namespace std;      //  a using-directive
```

然而，不管需要与否，都导出名称空间中的所有名称，是与名称空间的初衷背道而驰的。

稍微要好些的方法是，在函数中使用using编译指令，这将使名称在该函数中可用。

更好也是推荐的方法是，使用using声明或作用域解析运算符（::），只使程序需要的名称可用。例如，下面的代码使cin、cout和end1可用于文件的剩余部分：
```c++
#include <iostream>
using std::cin;       // a using-declaration
using std::cout;
using std::endl;
```

但使用作用域解析运算符只能使名称在使用该运算符的表达式中可用：
```c++
cout << std::fixed << x << endl;    // using the scope resolution operator
```

这样做可能很麻烦，但可以将通用的using声明放在一个头文件中：
```c++
// mynames - a header file
using std::cin;       // a using-declaration
using std::cout;
using std::endl;
```

还可以将通用的using声明放在一个名称空间中：
```c++
// mynames - a header file
using std::cin;       // a using-declaration
using std::cout;
using std::endl;

// mynames - a header file
#include <iostream>

namespace io
{
    using std::cin;
    using std::cout;
    using std::endl;
}

namespace formats
{
    using std::fixed;
    using std::scientific;
    using std::boolalpha;
}
```

这样，程序可以包含该文件，并使用所需的名称空间：
```c++
#include "mynames"
using namespace io;
```

## I.7 使用智能指针
每个new都应与delete配对使用。如果使用new的函数由于引发异常而提前结束，将导致问题。正如第15章介绍的，使用autoptr对象跟踪new创建的对象将自动完成delete操作。C++11新增的unique_ptr和shared_ptr提供了更佳的替代方案。

## I.8 使用string类
传统的C风格字符串深受不是真正的类型之苦。可以将字符串存储在字符数组中，也可以将字符数组初始化为字符串。但不能使用赋值运算符将字符串赋给字符数组，而必须使用strcpy( )或strncpy( )。不能使用关系运算符来比较C风格字符串，而必须使用strcmp( )（如果忘记了这一点，使用了>运算符，将不会出现语法错误，程序将比较字符串的地址，而不是字符串的内容）。

而string类（参见第16章和附录F）使得能够使用对象来表示字符串，并定义了赋值运算符、关系运算符和加法运算符（用于拼接）。另外，string类还提供了自动内存管理功能，因此通常不用担心字符串被保存前，有人可能会跨越数组边界或将字符串截短。

String类提供了许多方便的方法。例如，可以将一个string对象追加到另一个对象的后面，也可以将C风格的字符串，甚至char值追加到string对象的后面。对于接受C风格字符串参数的函数，可以使用c_str( )方法来返回一个适当的char指针。

string类不仅提供了一组设计良好的方法来处理与字符串相关的工作（如查找子字符串），而且与STL兼容，因此，可以将STL算法用于string对象。

## I.9 使用STL
标准模板库（请参见第16章和附录G）为许多编程需要提供了现成的解决方案，应使用它。例如，与其声明一个double或string对象数组，不如创建vector<double>对象或vector<string>对象。这样做的好处与使用string对象（而不是C风格字符串）相似。赋值运算符已被定义，因此可以使用赋值运算符将一个vector对象赋给另一个vector对象。可以按引用传递vector对象，接收这种对象的函数可以使用size( )方法来确定vector对象中元素数目。内置的内存管理功能使得当使用pushback( )方法在vector对象中添加元素时，其大小将自动调整。当然，还可以根据实际需要来使用其他有用的类方法和通用算法。在C++11中，如果长度固定的数组是更好的解决方案，可使用array<double>或array<string>。

如果需要链表、双端队列（或队列）、栈、常规队列、集合或映射，应使用STL，它提供了有用的容器模板。算法库使得可以将矢量的内容轻松地复制到链表中，或将集合的内容同矢量进行比较。这种设计使得STL成为一个工具箱，它提供了基本部件，可以根据自己的需要进行装配。

在设计内容广泛的算法库时，效率是一个主要的设计目标，因此只需要完成少量的编程工作，便可以得到最好的结果。另外，实现算法时使用了迭代器的概念，这意味着这些算法不仅可用于STL容器。具体地说，它们也可用于传统数组。






