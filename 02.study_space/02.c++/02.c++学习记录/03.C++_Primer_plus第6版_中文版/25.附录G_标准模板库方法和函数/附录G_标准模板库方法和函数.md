# 附录G 标准模板库方法和函数
标准模板库（STL）旨在提供通用算法的高效实现，它通过通用函数（可用于满足特定算法要求的任何容器）和方法（可用于特定容器类实例）来表达这些算法。本附录假设您对STL有一定的了解（如通过阅读第16章）。例如，本章假设您了解迭代器和构造函数。

## G.1 STL和C++11
C++11对C++语言做了大量修改，本书无法全面介绍，同样C++11对STL也做了大量修改，本附录无法全面介绍。然而，可以对新增的内容做一总结。

C++11给STL新增了多个元素。首先，它新增了多个容器；其次，给旧容器新增了多项功能；第三，在算法系列中新增了一些模板函数。本附录介绍了所有这些变化，对前两类变化有大致了解将很有帮助。

### G.1.1 新增的容器
C++11新增了如下容器：array、forward_list、unordered_st以及无序关联容器unordered_multiset、unordered_map和unordered_multimap。

array容器一旦声明，其长度就是固定的，它使用静态（栈）内存，而不是动态分配的内存。提供它旨在替代数组；array受到的限制比vector多，但效率更高。

容器list是一种双向链表，除两端的节点外，每个节点都链接到它前面和后面的节点。forward_list是一种单向链表，除最后一个节点外，每个节点都链接到下一个节点。相对于list，它更紧凑，但受到的限制更多。

与set和其他关联容器一样，无序关联容器让您能够使用键快速检索数据，差别在于关联容器使用的底层数据结构为树，而无序关联容器使用的是哈希表。

### G.1.2 对C++98容器所做的修改
C++11对容器类的方法做了三项主要修改。

首先，新增的右值引用使得能够给容器提供移动语义（参见第18章）。因此，STL现在给容器提供了移动构造函数和移动赋值运算符，这些方法将右值引用作为参数。

其次，由于新增了模板类initilizer_list（参见第18章），因此新增了将initilizer_list作为参数的构造函数和赋值运算符。这使得可以编写类似于下面的代码：
```c++
vector<int> vi{100, 99, 97, 98};
vi = {96, 99, 94, 95, 102};
```

第三，新增的可变参数模板（variadic template）和函数参数包（parameter pack）使得可以提供就地创建（emplacement）方法。这意味着什么呢？与移动语义一样，就地创建旨在提高效率。请看下面的代码段：
```c++
class Items
{
    double x;
    double y;
    int m;
public:
    Items();                              // #1
    Items(double xx, double yy, int mm);  // #2
    ...
};
...
vector<Items> vt(10);
...
vt.push_back(Items(8.2, 2.8, 3));   //
```

调用insert( )将导致内存分配函数在vt末尾创建一个默认Items对象。接下来，构造函数Items( )创建一个临时Items对象，该对象被复制到vt的开头，然后被删除。在C++11中，您可以这样做：
```c++
vi.emplace_back(8.2, 2.8, 3);
```

方法emplace_back( )是一个可变参数模板，将一个函数参数包作为参数：
```c++
template<class ... Args> void emplace_back(Args&&... args);
```

上述三个实参（8.2、2.8和3）将被封装到参数args中。参数args被传递给内存分配函数，而内存分配函数将其展开，并使用接受三个参数的Items构造函数（#2），而不是默认构造函数（#1）。也就是说，它使用Items(args…)，这里将展开为Items(8.2, 2.8, 3)。因此，将在矢量中就地创建所需的对象，而不是创建一个临时对象，再将其复制到矢量中。

STL在多个就地创建方法中使用了这种技术。

## G.2 大部分容器都有的成员
所有容器都定义了表G.1列出的类型。在这个表中，x为容器类型，如vector<int>；T为存储在容器中的类型，如int。表G.1中的示例阐明了含义

**表G.1 为所有容器定义的类型**

| 类 型 | 值 |
| :--- | :--- |
| x::value-type | T，元素类型 |
| x::reference | T & |
| x::const_reference | const T & |
| x::iterator | 指向T的迭代器类型，行为与T*相似 |
| x::const_iterator | 指向const T的迭代器类型，行为与const T *相似 |
| x::different_type | 用于表示两个迭代器之间距离的符号整型，如两个指针的差 |
| x::size_type | 无符号整型size_type可以表示数据对象的长度、元素数目和下标 |

类定义使用typedef定义这些成员。可以使用这些类型来声明适当的变量。例如，下面的代码使用迂回的方式，将由string对象组成的矢量中的第一个“bonus”替换为“bogus”，以演示如何使用成员类型来声明变量。
```c++
using namespace std;
vector<string> input;
string temp;
while(cin >> temp && temp != "quit")
    input.push_back(temp);
vector<string>::iterator want=
    find(input.begin(), input.end(), string("bonus"));
if (want != input.end())
{
    vector<string>::reference r = *want;
    r = "bonus";
}
```

上述代码使r成为一个指向（want指向的）input中元素的引用。同样，继续前面的例子，可以编写下面这样的代码：
```c++
vector<string>::value_type s1 = input[0];   // s1 is type string
vector<string>::reference s2 = input[1];    // s2 is type string &
```

这将导致s1为一个新string对象，它是input[0]的拷贝；而s2为指向input[1]的引用。在这个例子中，由于已经知道模板是基于string类型的，因此编写下面的等效代码将更简单：
```c++
string s1 = input[0];     // s1 is type string
string & s2 = input[1];   // s2 is type string &
```

然而，还可以在更通用的代码中使用表G.1中较精致（其中容器和元素的类型是通用的）的类型。例如，假设希望min( )函数将一个指向容器的引用作为参数，并返回容器中最小的项目。这假设为用于实例化模板的值类型定义了<运算符，而不想使用STL min_element( )算法，这种算法使用迭代器接口。由于参数可能是vector<int>、list<strint>或deque<double>，因此需要使用带模板参数（如Bag）的模板来表示容器（也就是说，Bag是一个模板类型，可能被实例化为vector<int>、list<string>或其他一些容器类型）。因此，函数的参数类型应为const Bag & b。返回类型是什么呢？应为容器的值类型，即Bag::value_type。然而，在这种情况下，Bag只是一个模板参数，编译器无法知道value_type成员实际上是一种类型。但可以使用typename关键字来指出，类成员是typedef：
```c++
vector<string>::value_type st;    // vector<string> a defined class
typename Bag::value_type m;       // Bag an as yet undefined type
```

对于上述第一个定义，编译器能够访问vector模板定义，该定义指出，value_type是一个typedef；对于第二个定义，typename关键字指出，无论Bag将会是什么，Bag::value-type都将是类型的名称。这些考虑因素导致了下面的定义：
```c++
template<typename Bag>
typename Bag::value_type min(const Bag & b)
{
    typename Bag::const_iterator it;
    typename Bag::value_type m = *b.begin();
    for (it = b.begin(); it != b.end(); ++it)
        if (*it < m)
            m = *it;
    return m;
}
```

这样，便可以这样使用该模板函数：
```c++
vector<int> temperatures;
// input temperature values into the vector
int coldest = min(temperatures);
```

temperatures参数将使得Bag被谓词为vector<int>，而typename Bag::value-type被谓词为vector<int>::value_type，进而为int。

所有的容器都还可以包含表G.2列出的成员函数或操作。其中，X是容器类型，如vector<int>；而T是存储在容器中的类型，如int。另外，a和b是类型为X的值；u是标识符；r是类型为X的非const值；rv是类型为X的非const右值，而移动操作是C++11新增的。

**表G.2 为所有容器定义的操作**

| 操 作 | 描 述 |
| :--- | :--- |
| X u; | 创建一个名为u的空对象 |
| X( ) | 创建一个空对象 |
| X(a) | 创建对象x的拷贝 |
| X u(a) | u是a的拷贝（复制构造函数） |
| X u = a; | u是a的拷贝（复制构造函数） |
| r = a | r等于a的值（复制赋值） |
| X u(rv) | u等于rv的原始值（移动构造函数） |
| X u = rv | u等于rv的原始值（移动构造函数） |
| a = rv | u等于rv的原始值（移动赋值） |
| (&a)->~X( ) | 对a的每个元素执行析构函数 |
| begin( ) | 返回一个指向第一个元素的迭代器 |
| end( ) | 返回一个指向超尾的迭代器 |
| cbegin( ) | 返回一个指向第一个元素的const迭代器 |
| cend( ) | 返回一个指向超尾的const迭代器 |
| size( ) | 返回元素数目 |
| maxsize( ) | 返回容器的最大可能长度 |
| empty( ) | 如果容器为空，则返回true |
| swap( ) | 交换两个容器的内容 |
| == | 如果两个容器的长度相同、包含的元素相同且元素排列的顺序相同，则返回true |
| != | a!=b返回!(a==b) |

使用双向或随机迭代器的容器（vector、list、deque、array、set和map）是可反转的，它们提供了表G.3所示的方法。

**表G.3 为可反转容器定义的类型和操作**

| 操 作 | 描 述 |
| :--- | :--- |
| X::reverse_iterator | 指向类型Ｔ的反向迭代器 |
| X::const_reverse_iterator | 指向类型Ｔ的const反向迭代器 |
| a.rbegin( ) | 返回一个反向迭代器，指向a的超尾 |
| a.rend( ) | 返回一个指向a的开头的反向迭代器 |
| a.crbegin( ) | 返回一个const反向迭代器，指向a的超尾 |
| a.crend( ) | 返回一个指向a的开头的const反向迭代器 |

无序集合（set）和无序映射（map）无需支持表G.4所示的可选容器操作，但其他容器必须支持。

**表G.4 可选的容器操作**

| 操 作 | 描 述 |
| :--- | :--- |
| < | 如果a按词典顺序排在b之前，则a<b返回true |
| > | a>b返回b<a |
| <= | a<=b返回!(a>b) |
| >= | a>=b返回!(a<b) |

容器的>运算符假设已经为值类型定义了>运算符。词典比较是一种广义的按字母顺序排序，它逐元素地比较两个容器，直到两个容器中对应的元素相同时为止。在这种情况下，元素对的顺序将决定容器的顺序。例如，如果两个容器的前10个元素都相同，但第一个容器的第11个元素比第二个容器的第11个元素小，则第一个容器将排在第二个容器之前。如果两个容器中的元素一直相同，直到其中一个容器中的元素用完，则较短的容器将排在较长的容器之前。

## G.3 序列容器的其他成员
模板类vector、forward_list、list、deque和array都是序列容器，它们都前面列出的方法，但forward_list不是可反转的，不支持表G.3所示的方法。序列容器以线性顺序存储一组类型相同的值。如果序列包含的元素数是固定的，通常选择使用array；否则，应首先考使用vector，它让array的随机存取功能以及添加和删除元素的功能于一身。然而，如果经常需要在序列中间添加元素，应考虑使用list或forward_list。如果添加和删除操作主要是在序列两端进行的，应考虑使用deque。

array对象的长度是固定的，因此无法使用众多序列方法。表G.5列出除array外的序列容器可用的其他方法（forward_list的resize( )方法的定义稍有不同）。同样，其中X是容器类型，如vector<int>；T是存储在容器中的类型，如int；a是类型为X的值；t是类型为x::value_type的左值或const右值；i和j是输入迭代器；[i, j]是有效的区间；il是类型为initilizer_list<value_type>的对象；p是指向a的有效const迭代器；q是可解除引用的有效const迭代器；[q1, q2]是有效的const迭代器区间；n是x::size_type类型的整数；Args是模板参数包，而args是形式为Args&&的函数参数包。

**表G.5 为序列容器定义的其他操作**

| 操 作 | 描 述 |
| :--- | :--- |
| X(n, t) | 创建一个序列容器，它包含t的n个拷贝 |
| X a(n, t) | 创建一个名为a的序列容器，它包含t的n个拷贝 |
| X(i, j) | 使用区间[i, j] 内的值创建一个序列容器 |
| X a(i, j) | 使用区间[i, j) 内的值创建一个名为a的序列容器 |
| X(il) | 创建一个序列容器，并将其初始化为il的内容 |
| a = il; | 将il的值复制到a中 |
| a.emplace(p,args); | 在p前面插入一个类型为Ｔ的对象，创建该对象时使用与args封装的参数匹配的构造函数 |
| a.insert(p, t) | 在p之前插入t的拷贝，并返回指向该拷贝的迭代器。T的默认值为T( )，即在没有显式初始化时，用于T类型的值 |
| a.insert(p, rv) | 在p之前插入rv的拷贝，并返回指向该拷贝的迭代器；可能使用移动语义 |
| a.insert(p, n, t) | 在p之前插入t的n个拷贝 |
| a.insert(p, i, j) | 在p之前插入[i, j)区间内元素的拷贝 |
| a.insert(p, il) | 等价于a.insert(p, il.begin( ), il.end( )) |
| a.resize(n) | 如果n > a.size( )，则在a.end( )之前插入n - a.size( )个元素；用于新元素的值为没有显式初始化时，用于T类型的值；如果n < a.size( )，则删除第n个元素之后的所有元素 |
| a.resize(n, t) | 如果n > a.size( )，则在a.end( )之前插入t的n - a.size( )个拷贝；如果n<a.size( )，则删除第n个元素之后的所有元素 |
| a.assign(i, j) | 使用区间[i，j)内的元素拷贝替换a当前的内容 |
| a.assign(n, t) | 使用t的n个拷贝替换a的当前内容。t的默认值为T( )，即在没有显式初始化时，用于T类型的值 |
| a.assign(il) | 等价于a.assign(il.begin( ), il.end( )) |
| a.erase(q) | 删除q指向的元素；返回一个指向q后面的元素的迭代器 |
| a.erase(q1, q2) | 删除区间[q1, q2]内的元素；返回一个迭代器，该迭代器指向q2原来指向的元素 |
| a.clear( ) | 与erase(a.begin( ), a.end( )) 等效 |
| a.front( ) | 返回*a.begin( )（第一个元素） |

表G.6列出了一些序列类（vector、forward_list、list和deque）都有的方法。

**表G.6 为某些序列定义的操作**

| 操 作 | 描 述 | 容 器 |
| :--- | :--- | :--- |
| a.back( ) | 返回*a.end( )（最后一个元素） | vector、list、deque |
| a.push_back(t) | 将t插入到a.end( )前面 | vector、list、deque |
| a.push_back(rv) | 将rv插入到a.end( )前面；可能使用移动语义 | vector、list、deque |
| a.pop_back( ) | 删除最后一个元素 | vector、list、deque |
| a.emplace_back(args) | 追加一个类型为T的对象，创建该对象时使用与args封装的参数匹配的构造函数 | vector、list、deque |
| a.push_front(t) | 将t的拷贝插入到第一个元素前面 | forward_list、list、deque |
| a.push_front(rv) | 将rv的拷贝插入到第一个元素前面；可能使用移动语义 | forward_list、list、deque |
| a.emplace_front( ) | 在最前面插入一个类型为T的对象，创建该对象时使用与args封装的参数匹配的构造函数 | forward_list、list、deque |
| a.pop_front( ) | 删除第一个元素 | forward_list、list |
| a[n] | 返回*(a.begin( )+ n) | vector、deque、array |
| a.at(n) | 返回*(a.begin( )+ n)；如果n>a.size，则引发out_of_range异常 | vector、deque、array |

模板vector还包含表G.7列出的方法。其中，a是vector容器，n是x::size_type型整数。

**表G.7 vector的其他操作**

| 操 作 | 描 述 |
| :--- | :--- |
| a.capacity( ) | 返回在不要求重新分配内存的情况下，矢量能存储的元素总量 |
| a.reserve(n) | 提醒a对象：至少需要存储n个元素的内存。调用该方法后，容量至少为n个元素。如果n大于当前的容量，则需要重新分配内存。如果n大于a.max_size( )，该方法将引发length_error异常 |

模板list还包含表G.8列出的方法。其中，a和b是list容器；T是存储在链表中的类型，如int；t是类型为T的值；i和j是输入迭代器；q2和p是迭代器；q和q1是可解除引用的迭代器；n是x::size_type型整数。该表使用了标准的STL表示法[i, j)，这指的是从i到j（不包括j）的区间。

**表G.8 list的其他操作**

| 方 法 | 描 述 |
| :--- | :--- |
| a.splice(p, b) | 将链表b的内容移到链表a中，并将它们插在p之前 |
| a.splice(p, b, i) | 将i指向的链表b中的元素移到链表a的p位置之前 |
| a.splice(p, b, i, j) | 将链表b中[i，j)区间内的元素移到链表a的p位置之前 |
| a.remove(const T& t) | 删除链表a中值为t的所有元素 |
| a.remove_if(Predicate pred) | 如果i是指向链表a中元素的迭代器，则删除pred(*i)为true的所有值（Predicate是布尔值函数或函数对象，参见第15章） |
| a.unique( ) | 删除连续的相同元素组中除第一个元素之外的所有元素 |
| a.unique(BinaryPredicate bin_pred) | 删除连续的bin_pred(*i, *(i - 1))为true的元素组中除第一个元素之外的所有元素（BinaryPredicate是布尔值函数或函数对象，参见第15章） |
| a.merge(b) | 使用为值类型定义的<运算符，将链表b与链表a的内容合并。如果链表a的某个元素与链表b的某个元素相同，则a中的元素将放在前面。合并后，链表b为空 |
| a.merge(b, Compare comp) | 使用comp函数或函数对象将链表b与链表a的内容合并。如果链表a的某个元素与链表b的某个元素相同，则链表a中的元素将放在前面。合并后，链表b为空 |
| a.sort( ) | 使用<运算符对链表a进行排序 |
| a.sort(Compare comp) | 使用comp函数或函数对象对链表a进行排序 |
| a.reverse( ) | 将链表a中的元素顺序反转 |

forward_list的操作与此类似，但由于模板类forward_list的迭代器不能后移，有些方法必须调整。因此，用insert_after( )、erase_after ( )和splice_after( )替代了insert( )、erase( )和splice( )，这些方法都对迭代器后面而不是前面的元素进行操作。

## G.4 set和map的其他操作
关联容器（集合和映射是这种容器的模型）带有模板参数Key和Compare，这两个参数分别表示用来对内容进行排序的键类型和用于对键值进行比较的函数对象（被称为比较对象）。对于set和multiset容器，存储的键就是存储的值，因此键类型与值类型相同。对于map和multimap容器，存储的值（模板参数T）与键类型（模板参数Key）相关联，值类型为pair<const Key, T>。关联容器有其他成员来描述这些特性，如表G.9所示。

**表G.9 为关联容器定义的类型**

| 类 型 | 值 |
| :--- | :--- |
| X::key_type | Key，键类型 |
| X::key_compare | Compare，默认为less<key_type> |
| X::value_compare | 二元谓词类型，与set和multiset的key_compare相同，为map或multimap容器中的pair<const Key, T>值提供了排序功能 |
| X::mapped_type | T，关联数据类型（仅限于map和multimap） |

关联容器提供了表G.10列出的方法。通常，比较对象不要求键相同的值是相同的；等价键（equivalent key）意味着两个值（可能相同，也可能不同）的键相同。在该表中，X为容器类，a是类型为X的对象。如果X使用唯一键（即为set或map），则a_uniq将是类型为X的对象。如果x使用多个键（即为multiset或multimap），则a_eq将是类型为X的对象。和前面一样，i和j也是指向value_type元素的输入迭代器，[i, j]是一个有效的区间，p和q2是指向a的迭代器，q和q1是指向a的可解除引用的迭代器，[q1, q2]是有效区间，t是X::value_type值（可能是一对），k是X::key_type值，而il是initializer_list<value_type>对象。

**表G.10 为set、multiset、map和multimap定义的操作**

| 操 作 | 描 述 |
| :--- | :--- |
| X(i, j, c) | 创建一个空容器，插入区间[i, j]中的元素，并将c用作比较对象 |
| X a(i, j, c) | 创建一个名为a的空容器，插入区间[i, j]中的元素，并将c用作比较对象 |
| X(i, j) | 创建一个空容器，插入区间[i, j]中的元素，并将Compare( )用作比较对象 |
| X a(i, j) | 创建一个名为a的空容器，插入区间[i, j]中的元素，并将Compare( )用作比较对象 |
| X(il); | 等价于X(il.begin( ), il.end( )) |
| a = il | 将区间[il.begin( ), il.end( )]的内容赋给a |
| a.key_comp( ) | 返回在构造a时使用的比较对象 |
| a.value_comp( ) | 返回一个value_compare对象 |
| a_uniq.insert(t) | 当且仅当a不包含具有相同键的值时，将t值插入到容器a中。该方法返回一个pair<iterator, bool>值。如果进行了插入，则bool的值为true，否则为false。iterator指向键与t相同的元素 |
| a_eq.insert(t) | 插入t并返回一个指向其位置的迭代器 |
| a.insert(p, t) | 将p作为insert( )开始搜索的位置，将t插入。如果a是键唯一的容器，则当且仅当a不包含拥有相同键的元素时，才插入；否则，将进行插入。无论是否进行了插入，该方法都将返回一个迭代器，该迭代器指向拥有相同键的位置 |
| a.insert(i, j) | 将区间[i, j]中的元素插入到a中 |
| a.insert(il) | 将initializer_list il中的元素插入到a中 |
| a_uniq.emplace(args) | 类似于a_uniq.insert(t)，但使用参数列表与参数包args的内容匹配的构造函数 |
| a_eq.emplace(args) | 类似于a_eq.insert(t)，但使用参数列表与参数包args的内容匹配的构造函数 |
| a.emplace_hint(args) | 类似于a.insert(p, t)，但使用参数列表与参数包args的内容匹配的构造函数 |
| a.erase(k) | 删除a中键与k相同的所有元素，并返回删除的元素数目 |
| a.erase(q) | 删除q指向的元素 |
| a.erase(q1, q2) | 删除区间[q1, q2)中的元素 |
| a.clear( ) | 与erase(a.begin( ), a.end( ))等效 |
| a.find(k) | 返回一个迭代器，该迭代器指向键与k相同的元素；如果没有找到这样的元素，则返回a.end( ) |
| a.count(k) | 返回键与k相同的元素的数量 |
| a.lower_bound(k) | 返回一个迭代器，该迭代器指向第一个键不小于k的元素 |
| a.upper_bound(k) | 返回一个迭代器，该迭代器指向第一个键大于k的元素 |
| a.equal_range(k) | 返回第一个成员为a.lower_bound(k)，第二个成员为a.upper_bound(k)的值对 |
| a.operator | 返回一个引用，该引用指向与键k关联的值（仅限于map容器） |

## G.4 无序关联容器（C++11）
前面说过，无序关联容器（unordered_set、unordered_multiset、unordered_map和unordered_multimap）使用键和哈希表，以便能够快速存取数据。下面简要地介绍这些概念。哈希函数（hash function）将键转换为索引值。例如，如果键为string对象，哈希函数可能将其中每个字符的数字编码相加，再计算结果除以13的余数，从而得到一个0～12的索引。而无序容器将使用13个桶（bucket）来存储string，所有索引为4的string都将存储在第4个桶中。如果您要在容器中搜索键，将对键执行哈希函数，进而只在索引对应的桶中搜索。理想情况下，应有足够多的桶，每个桶只包含为数不多的string。

C++11库提供了模板hash<key>，无序关联容器默认使用该模板。为各种整型、浮点型、指针以及一些模板类（如string）定义了该模板的具体化。

表G.11列出了用于这些容器的类型。

无序关联容器的接口类似于关联容器。具体地说，表G.10也适用于无序关联容器，但存在如下例外：不需要方法lower_bound( )和upper_bound( )，构造函数X(i, j, c) 亦如此。常规关联容器是经过排序的，这让它们能够使用表示“小于”概念的比较谓词。这种比较不适用于无序关联容器，因此它们使用基于概念“等于”的比较谓词。

**表G.11 为无序关联容器定义的类型**

| 类 型 | 值 |
| :--- | :--- |
| X::key_type | Key，键类型 |
| X::key_equal | Pred，一个二元谓词，检查两个类型为Key的参数是否相等 |
| X::hasher | Hash，一个这样的二元函数对象，即如果hf的类型为Hash，k的类型为Key，则hf(k) 的类型为std::size_t |
| X::local_iterator | 一个类型与X::iterator相同的迭代器，但只能用于一个桶 |
| X::const_local_iterator | 一个类型与X::const_iterator相同的迭代器，但只能用于一个桶 |
| X::mapped_type | T，关联数据类型（仅限于map和multimap） |

除表G.10所示的方法外，无序关联容器还包含其他一些必不可少的方法，如表G.12所示。在该表中，X为无序关联容器类，a是类型为X的对象，b可能是类型为X的常量对象，a_uniq是类型为unordered_set或unordered_map的对象，a_eq是类型为unordered_multiset或unordered_multimap的对象，hf是类型为hasher的值，eq是类型为key_equal的值，n是类型为size_type的值，z是类型为float的值。与以前一样，i和j也是指向value_type元素的输入迭代器，[i, j]是一个有效的区间，p和q2是指向a的迭代器，q和q1是指向a的可解除引用迭代器，[q1, q2]是有效区间，t是X::value_type值（可能是一对），k是X::key_type值，而il是initializer_list<value_type>对象。

**表G.12 为无序关联容器定义的操作**

| 操 作 | 描 述 |
| :--- | :--- |
| X(n, hf, eq) | 创建一个至少包含n个桶的空容器，并将hf用作哈希函数，将eq用作键值相等谓词。如果省略了eq，则将key_equal( )用作键值相等谓词；如果也省略了hf，则将hasher( )用作哈希函数 |
| X a(n, hf, eq) | 创建一个名为a的空容器，它至少包含n个桶，并将hf用作哈希函数，将eq用作键值相等谓词。如果省略eq，则将key_equal( )用作键值相等谓词；如果也省略了hf，则将hasher( )用作哈希函数 |
| X(i, j, n, hf, eq) | 创建一个至少包含n个桶的空容器，将hf用作哈希函数，将eq用作键值相等谓词，并插入区间[i, j]中的元素。如果省略了eq，将key_equal( )用作键值相等谓词；如果省略了hf，将hasher( )用作哈希函数；如果省略了n，则包含桶数不确定 |
| X a(i, j, n, hf, eq) | 创建一个名为a的的空容器，它至少包含n个桶，将hf用作哈希函数，将eq用作键值相等谓词，并插入区间[i, j]中的元素。如果省略了eq，将key_equal( )用作键值相等谓词；如果省略了hf，将hasher( )用作哈希函数；如果省略了n，则包含桶数不确定 |
| b.hash_function( ) | 返回b使用的哈希函数 |
| b.key_eq( ) | 返回创建b时使用的键值相等谓词 |
| b.bucket_count( ) | 返回b包含的桶数 |
| b.max_bucket_count( ) | 返回一个上限数，它指定了b最多可包含多少个桶 |
| b.bucket(k) | 返回键值为k的元素所属桶的索引 |
| b.bucket_size(n) | 返回索引为n的桶可包含的元素数 |
| b.begin(n) | 返回一个迭代器，它指向索引为n的桶中的第一个元素 |
| b.end(n) | 返回一个迭代器，它指向索引为n的桶中的最后一个元素 |
| b.cbegin(n) | 返回一个常量迭代器，它指向索引为n的桶中的第一个元素 |
| b.cend(n) | 返回一个常量迭代器，它指向索引为n的桶中的最后一个元素 |
| b.load_factor() | 返回每个桶包含的平均元素数 |
| b.max_load_factor() | 返回负载系数的最大可能取值；超过这个值后，容器将增加桶 |
| b.max_load_factor(z) | 可能修改最大负载系统，建议将它设置为z |
| a.rehash(n) | 将桶数调整为不小于n，并确保a.bucket_count( ) > a.size( ) / a.max_load_factor( ) |
| a.reserve(n) | 等价于a.rehash(ceil(n/a.max_load_factor( )))，其中ceil(x)返回不小于x的最小整数 |

## G.5 STL函数
STL算法库（由头文件algorithm和numeric支持）提供了大量基于迭代器的非成员模板函数。正如第16章介绍的，选择的模板参数名指出了特定参数应模拟的概念。例如，ForwardIterator用于指出，参数至少应模拟正向迭代器的要求；Predicate用于指出，参数应是一个接受一个参数并返回bool值的函数对象。C++标准将算法分成4组：非修改式序列操作、修改式序列操作、排序和相关运算符以及数值操作（C++11将数值操作从STL移到了numeric库中，但这不影响它们的用法）。序列操作（sequence operation）表明，函数将接受两个迭代器作为参数，它们定义了要操作的区间或序列。修改式（mutating）意味着函数可以修改容器的内容。

### G.5.1 非修改式序列操作
表G.13对非修改式序列操作进行了总结。这里没有列出参数，而重载函数只列出了一次。表后做了更详细的说明，其中包括原型。因此，可以浏览该表，以了解函数的功能，如果对某个函数非常感兴趣，则可以了解其细节。

**表G.13 非修改式序列操作**

| 函 数 | 描 述 |
| :--- | :--- |
| all_of( ) | 如果对于所有元素的谓词测试都为true，则返回true。这是C++11新增的 |
| any_of( ) | 只要对于任何一个元素的谓词测试为true，就返回true。这是C++11新增的 |
| none_of( ) | 如果对于所有元素的谓词测试都为false，则返回true。这是C++11新增的 |
| for_each( ) | 将一个非修改式函数对象用于区间中的每个成员 |
| find( ) | 在区间中查找某个值首次出现的位置 |
| find_if( ) | 在区间中查找第一个满足谓词测试条件的值 |
| find_if_not( ) | 在区间中查找第一个不满足谓词测试条件的值。这是C++11新增的 |
| find_end( ) | 在序列中查找最后一个与另一个序列匹配的值。匹配时可以使用等式或二元谓词 |
| find_first_of( ) | 在第二个序列中查找第一个与第一个序列的值匹配的元素。匹配时可以使用等式或二元谓词 |
| adjacent_find | 查找第一个与其后面的元素匹配的元素。匹配时可以使用等式或二元谓词 |
| count( ) | 返回特定值在区间中出现的次数 |
| count_if( ) | 返回特定值与区间中的值匹配的次数，匹配时使用二元谓词 |
| mismatch( ) | 查找区间中第一个与另一个区间中对应元素不匹配的元素，并返回指向这两个元素的迭代器。匹配时可以使用等式或二元谓词 |
| equal( ) | 如果一个区间中的每个元素都与另一个区间中的相应元素匹配，则返回true。匹配时可以使用等式或二元谓词 |
| is_permutation( ) | 如果可通过重新排列第二个区间，使得第一个区间和第二个区间对应的元素都匹配，则返回true，否则返回false。匹配可以是相等，也可以使用二元谓词进行判断。这是C++11新增的 |
| search( ) | 在序列中查找第一个与另一个序列的值匹配的值。匹配时可以使用等式或二元谓词 |
| search_n( ) | 查找第一个由n个元素组成的序列，其中每个元素都与给定值匹配。匹配时可以使用等式或二元谓词 |

下面更详细地讨论这些非修改型序列操作。对于每个函数，首先列出其原型，然后做简要地描述。和前面一样，迭代器对指出了区间，而选择的模板参数名指出了迭代器的类型。通常，[first, last]区间指的是从first到last（不包括last）。有些函数接受两个区间，这两个区间的容器类型可以不同。例如，可以使用equal( )来对链表和矢量进行比较。作为参数传递的函数是函数对象，这些函数对象可以是指针（如函数名），也可以是定义了( )操作的对象。正如第16章介绍的，谓词是接受一个参数的布尔函数，二元谓词是接受2个参数的布尔函数（函数可以不是bool类型，只要它对于false返回0，对于true返回非0值）。

1. all_of( )（C++11）
```c++
template<class InputIterator, class Predicate>
bool all_of(InputIterator first, InputIterator last, Predicate pred);
```

如果对于区间[first, last]中的每个迭代器，pred(*i)都为true，或者该区间为空，则函数all_of( )返回true；否则返回false。

2. any_of( )（C++11）
```c++
template<class InputIterator, class Predicate>
bool any_of(InputIterator first, InputIterator last, Predicate pred);
```

如果对于区间[first, last]中的每个迭代器，pred(*i)都为false，或者该区间为空，则函数any_of( )返回false；否则返回true。

3. none_of( )（C++11）
```c++
template<class InputIterator, class Predicate>
bool none_of(InputIterator first, InputIterator last, Predicate pred);
```

如果对于区间[first, last]中的每个迭代器，pred(*i)都为false，或者该区间为空，则函数all_of( )返回true；否则返回false。

4. for_each( )
```c++
template<class InputIterator, class Function>
Function for_each(InputIterator first, InputIterator last, Function f);
```

for_each( )函数将函数对象f用于[first, last]区间中的每个元素，它也返回f。

5. find( )
```c++
template<class InputIterator, class Predicate>
InputIterator find_if(InputIterator first, InputIterator last, Predicate pred);
```

find( )函数返回一个迭代器，该迭代器指向区间[first, last]中第一个值为value的元素；如果没有找到这样的元素，则返回last。

6. find_if( )
```c++
template<class InputIterator, class Predicate>
InputIterator find_if(InputIterator first, InputIterator last, Predicate pred);
```

find_if( )函数返一个迭代器，该迭代器指向[first, last]区间中第一个对其调用函数对象pred(*i)时结果为true的元素；如果没有找到这样的元素，则返回last。

7. find_if_not( )
```c++
template<class InputIterator, class Predicate>
InputIterator find_if_not(InputIterator first, InputIterator last, Predicate pred);
```

find_if_not( )函数返一个迭代器，该迭代器指向[first, last]区间中第一个对其调用函数对象pred(*i)时结果为false的元素；如果没有找到这样的元素，则返回last。

8. find_end( )
```c++
template<class ForwardIterator1, class ForwardIterator2>
ForwardIterator1 find_end(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2, ForwardIterator2 last2);

template<class ForwardIterator1, class ForwardIterator2,
         class BinaryPredicate>
ForwardIterator1 find_end(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2, ForwardIterator2 last2,
          BinaryPredicate pred);
```

find_end( )函数返回一个迭代器，该迭代器指向[first1, last1] 区间中最后一个与[first2, last2] 区间的内容匹配的序列的第一个元素。第一个版本使用值类型的= =运算符来比较元素；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素匹配。如果没有找到这样的元素，则它们都返回last1。

9. find_first_of( )
```c++
template<class ForwardIterator1, class ForwardIterator2>
ForwardIterator1 find_first_of(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2, ForwardIterator2 last2);

template<class ForwardIterator1, class ForwardIterator2,
         class BinaryPredicate>
ForwardIterator1 find_first_of(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2, ForwardIterator2 last2,
          BinaryPredicate pred);
```

find_first_of( ) 函数返回一个迭代器，该迭代器指向区间[first1, last1]中第一个与[first2, last2]区间中的任何元素匹配的元素。第一个版本使用值类型的= =运算符对元素进行比较；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素匹配。如果没有找到这样的元素，则它们都将返回last1。

10. adjacent_find( )
```c++
template<class ForwardIterator>
ForwardIterator adjacent_find(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class BinaryPredicate>
ForwardIterator adjacent_find(ForwardIterator first,
                ForwardIterator last, BinaryPredicate pred);
```

adjacent_find( )函数返回一个迭代器，该迭代器指向[first1, last1] 区间中第一个与其后面的元素匹配的元素。如果没有找到这样的元素，则返回last。第一个版本使用值类型的= =运算符来对元素进行比较；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素匹配。

11. count( )
```c++
template<class InputIterator, class T>
typename iterator_traits<InputIterator>::difference_type count(InputIterator first, InputIterator last, const T& value);
```

count( )函数返回[first, last)区间中与值value匹配的元素数目。对值进行比较时，将使用值类型的= =运算符。返回值类型为整型，它足以存储容器所能存储的最大元素数。

12. count_if( )
```c++
template<class InputIterator, class T>
typename iterator_traits<InputIterator>::difference_type count(InputIterator first, InputIterator last, const T& value);
```

count if( )函数返回[first, last]区间中这样的元素数目，即将其作为参数传递给函数对象pred时，后者的返回值为true。

13. mismatch( )
```c++
template<class InputIterator1, class InputIterator2>
pair<InputIterator1, InputIterator2> mismatch(InputIterator1 first1,
            InputIterator1 last1, InputIterator2 first2);

template<class InputIterator1, class InputIterator2,
          class BinaryPredicate>
pair<InputIterator1, InputIterator2> mismatch(InputIterator1 first1,
            InputIterator1 last1, InputIterator2 first2,
            BinaryPredicate pred);
```

每个mismatch( )函数都在[first1, last1)区间中查找第一个与从first2开始的区间中相应元素不匹配的元素，并返回两个迭代器，它们指向不匹配的两个元素。如果没有发现不匹配的情况，则返回值为pair< last1,first2 + (last1 - first1) >。第一个版本使用= =运算符来测试匹配情况；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为false，则it1和it2指向的元素不匹配。

14. equal( )
```c++
template<class InputIterator1, class InputIterator2>
bool equal(InputIterator1 first1, InputIterator1 last1,
           InputIterator2 first2);

template<class InputIterator1, class InputIterator2,
         class BinaryPredicate>
bool equal(InputIterator1 first1, InputIterator1 last1,
           InputIterator2 first2, BinaryPredicate pred);
```

如果[first1, last1)区间中每个元素都与以first2开始的序列中相应元素匹配，则equal( )函数返回true，否则返回false。第一个版本使用值类型的= =运算符来比较元素；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素匹配。

15. is_permutation( )（C++11）
```c++
template<class InputIterator1, class InputIterator2>
bool is_permutation(InputIterator1 first1, InputIterator1 last1,
           InputIterator2 first2);

template<class InputIterator1, class InputIterator2,
         class BinaryPredicate>
bool is_permutation(InputIterator1 first1, InputIterator1 last1,
           InputIterator2 first2, BinaryPredicate pred);
```

如果通过对从first2开始的序列进行排列，可使其与区间[first1, last1]相应的元素匹配，则函数is_permutation( )返回true，否则返回false。第一个版本使用值类型的==运算符来比较元素；第二个版本使用二元谓词函数对象pred来比较元素，也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素匹配。

16. search( )
```c++
template<class ForwardIterator1, class ForwardIterator2>
ForwardIterator1 search(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2, ForwardIterator2 last2);

template<class ForwardIterator1, class ForwardIterator2,
         class BinaryPredicate>
ForwardIterator1 search(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2, ForwardIterator2 last2,
          BinaryPredicate pred);
```

search( )函数在[first1, last1]区间中搜索第一个与[first2, last2] 区间中相应的序列匹配的序列；如果没有找到这样的序列，则返回last1。第一个版本使用值类型的= =运算符来对元素进行比较；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素是匹配的。

17. search_n( )
```c++
template<class ForwardIterator, class Size, class T>
ForwardIterator search_n(ForwardIterator first, ForwardIterator last,
                         Size count, const T& value);

template<class ForwardIterator, class Size, class T, class BinaryPredicate>
ForwardIterator search_n(ForwardIterator first, ForwardIterator last,
                         Size count, const T& value, BinaryPredicate pred);
```

search_n( )函数在[first1, last1)区间中查找第一个与count个value组成的序列匹配的序列；如果没有找到这样的序列，则返回last1。第一个版本使用值类型的= =运算符来对元素进行比较；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素是匹配的。

### G.5.2 修改式序列操作
表G.14对修改式序列操作进行了总结。其中没有列出参数，而重载函数也只列出了一次。表后做了更详细的说明，其中包括原型。因此，可以浏览该表，以了解函数的功能，如果对某个函数非常感兴趣，则可以了解其细节。

**表G.14 修改式序列操作**

| 函 数 | 描 述 |
| :--- | :--- |
| copy( ) | 将一个区间中的元素复制到迭代器指定的位置 |
| copy_n( ) | 从一个迭代器指定的地方复制n个元素到另一个迭代器指定的地方，这是C++11新增的 |
| copy_if( ) | 将一个区间中满足谓词测试的元素复制到迭代器指定的地方，这是C++11新增的 |
| copy_backward( ) | 将一个区间中的元素复制到迭代器指定的地方。复制时从区间结尾开始，由后向前进行 |
| move( ) | 将一个区间中的元素移到迭代器指定的地方，这是C++11新增的 |
| move_backward( ) | 将一个区间中的元素移到迭代器指定的地方；移动时从区间结尾开始，由后向前进行。这是C++11新增的 |
| swap( ) | 交换引用指定的位置中存储的值 |
| swap_ranges( ) | 对两个区间中对应的值进行交换 |
| iter_swap( ) | 交换迭代器指定的位置中存储的值 |
| transform( ) | 将函数对象用于区间中的每一个元素（或区间对中的每对元素），并将返回的值复制到另一个区间的相应位置 |
| replace( ) | 用另外一个值替换区间中某个值的每个实例 |
| replace_if( ) | 如果用于原始值的谓词函数对象返回true，则使用另一个值来替换区间中某个值的所有实例 |
| replace_copy( ) | 将一个区间复制到另一个区间中，使用另外一个值替换指定值的每个实例 |
| replace_copy_if( ) | 将一个区间复制到另一个区间，使用指定值替换谓词函数对象为true的每个值 |
| fill( ) | 将区间中的每一个值设置为指定的值 |
| fill_n( ) | 将n个连续元素设置为一个值 |
| generate( ) | 将区间中的每个值设置为生成器的返回值，生成器是一个不接受任何参数的函数对象 |
| generate_n( ) | 将区间中的前n个值设置为生成器的返回值，生成器是一个不接受任何参数的函数对象 |
| remove( ) | 删除区间中指定值的所有实例，并返回一个迭代器，该迭代器指向得到的区间的超尾 |
| remove_if( ) | 将谓词对象返回true的值从区间中删除，并返回一个迭代器，该迭代器指向得到的区间的超尾 |
| remove_copy( ) | 将一个区间中的元素复制到另一个区间中，复制时忽略与指定值相同的元素 |
| remove_copy_if( ) | 将一个区间中的元素复制到另一个区间中，复制时忽略谓词函数对象返回true的元素 |
| unique( ) | 将区间内两个或多个相同元素组成的序列压缩为一个元素 |
| unique_copy( ) | 将一个区间中的元素复制到另一个区间中，并将两个或多个相同元素组成的序列压缩为一个元素 |
| reverse( ) | 反转区间中的元素的排列顺序 |
| reverse_copy( ) | 按相反的顺序将一个区间中的元素复制到另一个区间中 |
| rotate( ) | 将区间中的元素循环排列，并将元素左转 |
| rotate_copy( ) | 以旋转顺序将区间中的元素复制到另一个区间中 |
| random_shuffle( ) | 随机重新排列区间中的元素 |
| shuffle( ) | 随机重新排列区间中的元素，使用的函数对象满足C++11对统一随机生成器的要求 |
| is_partitioned( ) | 如果区间根据指定的谓词进行了分区，则返回true |
| partition( ) | 将满足谓词函数对象的所有元素都放在不满足谓词函数对象的元素之前 |
| stable_partition( ) | 将满足谓词函数对象的所有元素放置在不满足谓词函数对象的元素之前，每组中元素的相对顺序保持不变 |
| partition_copy( ) | 将满足谓词函数对象的所有元素都复制到一个输出区间中，并将其他元素都复制到另一个输出区间中，这是C++11新增的 |
| partition_point( ) | 对于根据指定谓词进行了分区的区间，返回一个迭代器，该迭代器指向第一个不满足该谓词的元素 |

下面详细地介绍这些修改型序列操作。对于每个函数，首先列出其原型，然后做简要的描述。正如前面介绍的，迭代器对指出了区间，而选择的模板参数名指出了迭代器的类型。通常，[first, last]区间指的是从first到last（不包括last）。作为参数传递的函数是函数对象，这些函数对象可以是指针，也可以是定义了( )操作的对象。正如第16章介绍的，谓词是接受一个参数的布尔函数，二元谓词是接受两个参数的布尔函数（函数可以不是bool类型，只要它对于false返回0，对于true返回非0值）。另外，正如第16章介绍的，一元函数对象接受一个参数，而二元函数对象接受两个参数。

1. copy( )
```c++
template<class InputIterator, class OutputIterator>
OutputIterator copy(InputIterator first, InputIterator last,
                    OutputIterator result);
```

copy( )函数将[first, last)区间中的元素复制到区间[result, result + (last – first))中，并返回result + (last – first)，即指向被复制到的最后一个位置后面的迭代器。该函数要求result不位于[first, last)区间中，也就是说，目标不能与源重叠。

2. copy_n( )（C++11）
```c++
template<class InputIterator, class Size, class OutputIterator>
OutputIterator copy(InputIterator first, Size n,
                    OutputIterator result);
```

函数copy_n( )从位置first开始复制n个元素到区间[result, result + n]中，并返回result + n，即指向被复制到的最后一个位置后面的迭代器。该函数不要求目标和源不重叠。

3. copy_if( )（C++11）
```c++
template<class InputIterator, class Size, class OutputIterator,
         class Predicate>
OutputIterator copy_if(InputIterator first, InputIterator last,
                    OutputIterator result, Predicate pred);
```

函数copy_if( )将[first, last)区间中满足谓词pred的元素复制到区间[result, result + (last – first))中，并返回result + (last – first)，即指向被复制到的最后一个位置后面的迭代器。该函数要求result不位于[first, last)区间中，也就是说，目标不能与源重叠。

4. copy_backward( )
```c++
template<class BidirectionalIterator1,
         class BidirectionalIterator2>
BidirectionalIterator2 copy_backward(BidirectionalIterator1 first,
    BidirectionalIterator1 last, BidirectionalIterator2 result);
```

函数copy_backward( )将[first, last)区间中的元素复制到区间[result - (last - first), result)中。复制从last - 1开始，该元素被复制到位置result - 1，然后由后向前处理，直到first。该函数返回result - (last - first)，即指向被复制到的最后一个位置后面的迭代器。该函数要求result不位于[first, last)区间中。然而，由于复制是从后向前进行的，因此目标和源可能重叠。

5. move( )（C++11）
```c++
template<class InputIterator, class Size, class OutputIterator>
OutputIterator copy(InputIterator first, InputIterator last,
                    OutputIterator result);
```

函数move( )使用std::move( )将[first, last)区间中的元素移到区间[result, result + (last – first))中，并返回result + (last – first)，即指向被复制到的最后一个位置后面的迭代器。该函数要求result不位于[first, last)区间中，也就是说，目标不能与源重叠。

6. move_backward( )（C++11）
```c++
template<class BidirectionalIterator1,
         class BidirectionalIterator2>
BidirectionalIterator2 copy_backward(BidirectionalIterator1 first,
    BidirectionalIterator1 last, BidirectionalIterator2 result);
```

函数move_backward( ) std::move( )将[first, last)区间中的元素移到区间[result - (last - first), result)中。复制从last - 1开始，该元素被复制到位置result - 1，然后由后向前处理，直到first。该函数返回result - (last - first)，即指向被复制到的最后一个位置后面的迭代器。该函数要求result不位于[first, last)区间中。然而，由于复制是从后向前进行的，因此目标和源可能重叠。

7. swap( )
```c++
template<class T> void swap(T& a, T& b);
```

swap( )函数对引用指定的两个位置中存储的值进行交换（C++11将这个函数移到了头文件utility中）。

8. swap_ranges( )
```c++
template<class ForwardIterator1, class ForwardIterator2>
ForwardIterator2 swap_ranges(
          ForwardIterator1 first1, ForwardIterator1 last1,
          ForwardIterator2 first2);
```

swap_ranges( )函数将[first1, last1]区间中的值与从first2开始的区间中对应的值交换。这两个区间不能重叠。

9. iter_swap( )
```c++
template<class ForwardIterator1, class ForwardIterator2>
void iter_swap(ForwardIterator1 a, ForwardIterator2 b);
```

iter_swap( )函数将迭代器指定的两个位置中存储的值进行交换。

10. transform( )
```c++
template<class InputIterator, class OutputIterator, class UnaryOperation>
OutputIterator transform(InputIterator first, InputIterator last,
                         OutputIterator result, UnaryOperation op);
template<class InputIterator1, class InputIterator2,  class OutputIterator, class BinaryOperation>
OutputIterator transform(InputIterator1 first1, InputIterator1 last1,
                         InputIterator2 first2, OutputIterator result,
                         BinaryOperation binary_op);
```

第一个版本的transform( )将一元函数对象op应用到[first, last)区间中每个元素，并将返回值赋给从result开始的区间中对应的元素。因此，* result被设置为op(* first)，依此类推。该函数返回result + (last - first)，即目标区间的超尾值。

第二个版本的transform( )将二元函数对象op应用到[first1, last1)区间和[first2, last2)区间中的每个元素，并将返回值赋给从result开始的区间中对应的元素。因此，* result被设置成op(* first1, * first2)，依此类推。该函数返回result + (last – first)，即目标区间的超尾值。

11. replace( )
```c++
template<class ForwardIterator, class T>
void replace(ForwardIterator first, ForwardIterator last,
             const T& old_value, const T& new_value);
```

replace( )函数将[first, last]中的所有old_value替换为new_value。

12. replace_if( )
```c++
template<class ForwardIterator, class Predicate, class T>
void replace_if(ForwardIterator first, ForwardIterator last,
                Predicate pred, const T& new_value);
```

replace_if( )函数使用new_value值替换[first, last]区间中pred（old）为true的每个old值。

13. replace_copy( )
```c++
template<class InputIterator, class OutputIterator, class T>
OutputIterator replace_copy(InputIterator first, InputIterator last,
                            OutputIterator result, const T& old_value, const T& new_value);
```

replace_copy( )函数将[first, last]区间中的元素复制到从result开始的区间中，但它使用new_value代替所有的old_value。该函数返回result + (last - first)，即目标区间的超尾值。

14. replace_copy_if( )
```c++
template<class Iterator, class OutputIterator, class Predicate, class T>
OutputIterator replace_copy_if(Iterator first, Iterator last,
                            OutputIterator result, Predicate pred, const T& new_value);
```

replace_copy_if( )函数将[first, last]区间中的元素复制到从result开始的区间中，但它使用new_value代替pred(old)为true的所有old值。该函数返回result + (last - first)，即目标区间的超尾值。

15. fill( )
```c++
template<class ForwardIterator, class T>
void fill(ForwardIterator first, ForwardIterator last, const T& value);
```

fill( )函数将[first, last]区间中的每个元素都设置为value。

16. fill_n( )
```c++
template<class OutputIterator, class Size, class T>
void fill_n(OutputIterator first, Size n, const T& value);
```

fill_n( )函数将从first位置开始的前n个元素都设置为value。

17. generate( )
```c++
template<class ForwardIterator, class Generator>
void generate(ForwardIterator first, ForwardIterator last, Generator gen);
```

generate( )函数将[first, last)区间中的每个元素都设置为gen( )，其中gen是一个生成器函数对象，即不接受任何参数。例如，gen可以是一个指向rand( )的指针。

18. generate_n( )
```c++
template<class OutputIterator, class Size, class Generator>
void generate_n(OutputIterator first, Size n, Generator gen);
```

generate_n( )函数将从first开始的区间中前n个元素都设置为gen( )，其中，gen是一个生成器函数对象，即不接受任何参数。例如，gen可以是一个指向rand( )的指针。

19. remove( )
```c++
template<class ForwardIterator, class T>
ForwardIterator remove(ForwardIterator first, ForwardIterator last, const T& value);
```

remove( )函数删除[first, last)区间中所有值为value的元素，并返回得到的区间的超尾迭代器。该函数是稳定的，这意味着未删除的元素的顺序将保持不变。

注意：由于所有的remove( )和unique( )函数都不是成员函数，同时这些函数并非只能用于STL容器，因此它们不能重新设置容器的长度。相反，它们返回一个指示新超尾位置的迭代器。通常，被删除的元素只是被移到容器尾部。然而，对于STL容器，可以使用返回的迭代器和erase( )方法来重新设置end( )。

20. remove_if( )
```c++
template<class ForwardIterator, class Predicate>
ForwardIterator remove_if(ForwardIterator first, ForwardIterator last, Predicate pred);
```

remove_if( )函数将pred(val)为true的所有val值从[first, last)区间删除，并返回得到的区间的超尾迭代器。该函数是稳定的，这意味着未删除的元素的顺序将保持不变。

21. remove_copy( )
```c++
template<class InputIterator, class OutputIterator, class T>
OutputIterator remove_copy(InputIterator first, InputIterator last,
                           OutputIterator result, const T& value);
```

remove_copy( )函数将[first, last)区间中的值复制到从result开始的区间中，复制时将忽略value。该函数返回得到的区间的超尾迭代器。该函数是稳定的，这意味着没有被删除的元素的顺序将保持不变。

22. remove_copy_if( )
```c++
template<class InputIterator, class OutputIterator, class Predicate>
OutputIterator remove_copy_if(InputIterator first, InputIterator last,
                           OutputIterator result, const T& value);
```

remove_copy_if( )函数将[first, last)区间中的值复制到从result开始的区间，但复制时忽略pred(val)为true的val。该函数返回得到的区间的超尾迭代器。该函数是稳定的，这意味着没有删除的元素的顺序将保持不变。

23. unique( )
```c++
template<class ForwardIterator>
ForwardIterator unique(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class BinaryPredicate>
ForwardIterator unique(ForwardIterator first, ForwardIterator last, BinaryPredicate pred);
```

unique( )函数将[first, last)区间中由两个或更多相同元素构成的序列压缩为一个元素，并返回新区间的超尾迭代器。第一个版本使用值类型的==运算符对元素进行比较；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素是匹配的。

24. unique_copy( )
```c++
template<class InputIterator, class OutputIterator>
OutputIterator unique_copy(InputIterator first, InputIterator last,
                           OutputIterator result);

template<class InputIterator, class OutputIterator, class BinaryPredicate>
OutputIterator unique_copy(InputIterator first, InputIterator last,
                           OutputIterator result, BinaryPredicate pred);
```

unique_copy( )函数将[first, last)区间中的元素复制到从result开始的区间中，并将由两个或更多个相同元素组成的序列压缩为一个元素。该函数返回新区间的超尾迭代器。第一个版本使用值类型的= =运算符，对元素进行比较；第二个版本使用二元谓词函数对象pred来比较元素。也就是说，如果pred(*it1, *it2)为true，则it1和it2指向的元素是匹配的。

25. reverse( )
```c++
template<class BidirectionalIterator>
void reverse(BidirectionalIterator first, BidirectionalIterator last);
```

reverse( )函数通过调用swap(first, last - 1)等来反转[first, last]区间中的元素。

26. reverse_copy
```c++
template<class BidirectionalIterator, class OutputIterator>
OutputIterator reverse_copy(BidirectionalIterator first,
                            BidirectionalIterator last,
                            OutputIterator result);
```

reverse_copy( )函数按相反的顺序将[first, last)区间中的元素复制到从result开始的区间中。这两个区间不能重叠。

27. rotate( )
```c++
template<class ForwardIterator>
void rotate(ForwardIterator first, ForwardIterator middle,
            ForwardIterator last);
```

rotate( )函数将[first, last)区间中的元素左旋。middle处的元素被移到first处，middle + 1处的元素被移到first + 1处，依此类推。middle前的元素绕回到容器尾部，以便first处的元素可以紧接着last - 1处的元素。

28. rotate_copy( )
```c++
template<class ForwardIterator, class OutputIterator>
OutputIterator rotate_copy(ForwardIterator first, ForwardIterator middle,
                           ForwardIterator last, OutputIterator result);
```

rotate_copy( )函数使用为rotate( )函数描述的旋转序列，将[first, last)区间中的元素复制到从result开始的区间中。

29. random_shuffle( )
```c++
template<class RandomAccessIterator>
void random_shuffle(RandomAccessIterator first, RandomAccessIterator last);
```

这个版本的random_shuffle( )函数将[first, last)区间中的元素打乱。分布是一致的，即原始顺序的每种可能排列方式出现的概率相同。

30. random_shuffle( )
```c++
template<class RandomAccessIterator, class RandomNumberGenerator>
void random_shuffle(RandomAccessIterator first, RandomAccessIterator last,
                    RandomNumberGenerator&& random);
```

这个版本的random_shuffle( )函数将[first, last)区间中的元素打乱。函数对象random确定分布。假设有n个元素，表达式random(n)将返回[0, n)区间中的一个值。在C++98中，参数random是一个左值引用，而在C++11中是一个右值引用。

31. shuffle( )
```c++
template<class RandomAccessIterator, class UniformRandomNumberGenerator>
void shuffle(RandomAccessIterator first, RandomAccessIterator last,
                    UniformRandomNumberGenerator&& rgen);
```

函数shuffle( )将[first, last)区间中的元素打乱。函数对象rgen确定分布，它应满足C++11指定的有关均匀随机数生成器的要求。假设有n个元素，表达式rgen(n)将返回[0, n]区间中的一个值。

32. is_partitioned( )（C++11）
```c++
template<class InputIterator, class Predicate>
void is_partitioned(InputIterator first, InputIterator last,
                    Predicate pred);
```

如果区间为空或根据pred进行了分区（即满足谓词pred的元素都在不满足该谓词的元素前面），函数is__partitioned( )将返回true，否则返回false。

33. partition( )
```c++
template<class BidirectionalIterator, class Predicate>
BidirectionalIterator partition(BidirectionalIterator first,
                                BidirectionalIterator last,
                                Predicate pred);
```

函数partition( )将其值val使得pred(val)为true的元素都放在不满足该测试条件的所有元素之前。这个函数返回一个迭代器，指向最后一个使得谓词对象函数为true的值的后面。

34. stable_partition( )
```c++
template<class BidirectionalIterator, class Predicate>
BidirectionalIterator stable_partition(BidirectionalIterator first,
                                       BidirectionalIterator last,
                                       Predicate pred);
```

函数stable_partition( )将其值val使得pred(val)为true的元素都放在不满足该测试条件的所有元素之前；在这两组中，元素的相对顺序保持不变。这个函数返回一个迭代器，指向最后一个使得谓词对象函数为true的值的后面。

35. partition_copy( )（C++11）
```c++
template<class InputIterator, class OutputIterator1,
         class OutputIterator2, class Predicate>
pair<OutputIterator1, OutputIterator2> partition_copy(
         InputIterator first, InputIterator last,
         OutputIterator1 out_true, OutputIterator2 out_false,
         Predicate pred);
```

函数partition_copy( )将所有这样的元素都复制到从out_true开始的区间中，即其值val使得pred(val)为true；并将其他的元素都复制到从out_false开始的区间中。它返回一个pair对象，该对象包含两个迭代器，分别指向从out_true和out_false开始的区间的末尾。

36. partition_point( )（C++11）
```c++
template<class ForwardIterator, class Predicate>
ForwardIterator partition_point(ForwardIterator first,
                                ForwardIterator last,
                                Predicate pred);
```

函数partition_point( )要求区间根据pred进行了分区。它返回一个迭代器，指向最后一个让谓词对象函数为true的值所在的位置。

### G.5.3 排序和相关操作
表G.15对排序和相关操作进行了总结。其中没有列出参数，而重载函数也只列出了一次。每一个函数都有一个使用<对元素进行排序的版本和一个使用比较函数对象对元素进行排序的版本。表后做了更详细的说明，其中包括原型。因此，可以浏览该表，以了解函数的功能，如果对某个函数非常感兴趣，则可以了解其细节。

**表G.15 排序和相关操作**

| 函 数 | 描 述 |
| :--- | :--- |
| sort( ) | 对区间进行排序 |
| stable_sort( ) | 对区间进行排序，并保留相同元素的相对顺序 |
| partial_sort( ) | 对区间进行部分排序，提供完整排序的前n个元素 |
| partial_sort_copy( ) | 将经过部分排序的区间复制到另一个区间中 |
| is_sorted( ) | 如果对区间进行了排序，则返回true，这是C++11新增的 |
| is_sorted_until( ) | 返回一个迭代器，指向经过排序的区间末尾，这是C++11新增的 |
| nth_element( ) | 对于给定指向区间的迭代器，找到区间被排序时，相应位置将存储哪个元素，并将该元素放到这里 |
| lower_bound( ) | 对于给定的一个值，在一个排序后的区间中找到第一个这样的位置，使得将这个值插入到这个位置前面时，不会破坏顺序 |
| upper_bound( ) | 对于给定的一个值，在一个排序后的区间中找到最后一个这样的位置，使得将这个值插入到这个位置前面时，不会破坏顺序 |
| equal_range( ) | 对于给定的一个值，在一个排序后的区间中找到一个最大的区间，使得将这个值插入其中的任何位置，都不会破坏顺序 |
| binary_search( ) | 如果排序后的区间中包含了与给定的值相同的值，则返回true，否则返回false |
| merge( ) | 将两个排序后的区间合并为第三个区间 |
| inplace_merge( ) | 就地合并两个相邻的、排序后的区间 |
| includes( ) | 如果对于一个集合中的每个元素都可以在另外一个集合中找到，则返回true |
| set_union( ) | 构造两个集合的并集，其中包含在任何一个集合中出现过的元素 |
| set_intersection( ) | 构造两个集合的交集，其中包含在两个集合中都出现过的元素 |
| set_difference( ) | 构造两个集合的差集，即包含第一个集合中且没有出现在第二个集合中的所有元素 |
| set_symmetric_difference( ) | 构造由只出现在其中一个集合中的元素组成的集合 |
| make_heap( ) | 将区间转换成堆 |
| push_heap( ) | 将一个元素添加到堆中 |
| pop_heap( ) | 删除堆中最大的元素 |
| sort_heap( ) | 对堆进行排序 |
| is_heap( ) | 如果区间是堆，则返回true，这是C++11新增的 |
| is_heap_until( ) | 返回一个迭代器，指向属于堆的区间的末尾，这是C++11新增的 |
| min( ) | 返回两个值中较小的值，如果参数为initializer_list，则返回最小的元素（这是C++11新增的） |
| max( ) | 返回两个值中较大的值，如果参数为initializer_list，则返回最大的元素（这是C++11新增的） |
| minmax( ) | 返回一个pair对象，其中包含按递增顺序排列的两个参数；如果参数为initializer_list，则返回pair对象包含最小和最大的元素。这是C++11新增的 |
| min_element( ) | 在区间找到最小值第一次出现的位置 |
| max_element( ) | 在区间找到最大值第一次出现的位置 |
| minmax_element( ) | 返回一个pair对象，其中包含两个迭代器，它们分别指向区间中最小值第一次出现的位置和区间中最大值最后一次出现的位置。这是C++11新增的 |
| lexicographic_compare( ) | 按字母顺序比较两个序列，如果第一个序列小于第二个序列，则返回true，否则返回false |
| next-permutation( ) | 生成序列的下一种排列方式 |
| previous_permutation( ) | 生成序列的前一种排列方式 |

本节中的函数使用为元素定义的<运算符或模板类型Compare指定的比较对象来确定两个元素的顺序。如果comp是一个Compare类型的对象，则comp(a, b)就是a < b的统称，如果在排序机制中，a在b之前，则返回true。如果a < b返回fasle，同时b < a也返回false，则说明a和b相等。比较对象必须至少提供严格弱排序功能（strict weak ordering）。这意味着：

* 表达式comp(a, a)一定为false，这是“值不能比其本身小”的统称（这是严格部分）。
* 如果comp(a, b)为true，且comp(b, c)也为true，则comp(a, c)为true（也就是说，比较是一种可传递的关系）。
* 如果a与b等价，且b与c也等价，则a与c等价（也就是说，等价也是一种可传递的关系）。

如果想将<运算符用于整数，则等价就意味着相等，但这一结论不能推而广之。例如，可以用几个描述邮件地址的成员来定义一个结构，同时定义一个根据邮政编码对结构进行排序的comp对象。则邮政编码相同的地址是等价的，但它们并不相等。

下面更详细地介绍排序及相关操作。对于每个函数，首先列出其原型，然后做简要的说明。我们将这一节分成几个小节。正如前面介绍的，迭代器对指出了区间，而选择的模板参数名指出了迭代器的类型。通常，[first, last)区间指的是从first到last（不包括last）。作为参数传递的函数是函数对象，这些函数对象可以是指针，也可以是定义了( )操作的对象。正如第16章介绍的，谓词是接受一个参数的布尔函数，二元谓词是接受2个参数的布尔函数（函数可以不是bool类型，只要它对于false返回0，对于true返回非0值）。另外，正如第16章介绍的，一元函数对象接受一个参数，而二元函数对象接受两个参数。

1. 排序

首先来看看排序算法。

（1）sort( )
```c++
template<class RandomAccessIterator>
void sort(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void sort(RandomAccessIterator first, RandomAccessIterator last,
          Compare comp);
```

sort( )函数将[first, last)区间按升序进行排序，排序时使用值类型的 < 运算符进行比较。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（2）stable_sort( )
```c++
template<class RandomAccessIterator>
void stable_sort(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void stable_sort(RandomAccessIterator first, RandomAccessIterator last,
          Compare comp);
```

stable_sort( )函数对[first, last)区间进行排序，并保持等价元素的相对顺序不变。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（3）partial_sort( )
```c++
template<class RandomAccessIterator>
void partial_sort(RandomAccessIterator first, RandomAccessIterator middle,
                  RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void partial_sort(RandomAccessIterator first, RandomAccessIterator middle,
                  RandomAccessIterator last, Compare comp);
```

partial_sort( )函数对[first, last)区间进行部分排序。将排序后的区间的前middle - first个元素置于[first, middle]区间内，其余元素没有排序。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（4）partial_sort_copy( )
```c++
template<class InputIterator, class RandomAccessIterator>
RandomAccessIterator partial_sort_copy(InputIterator first, 
                                       InputIterator last,
                                       RandomAccessIterator result_first,
                                       RandomAccessIterator result_last);

template<class InputIterator, class RandomAccessIterator, class Compare>
RandomAccessIterator partial_sort_copy(InputIterator first, 
                                       InputIterator last,
                                       RandomAccessIterator result_first,
                                       RandomAccessIterator result_last,
                                       Compare comp);
```

partial_sort_copy( )函数将排序后的区间[first, last]中的前n个元素复制到区间[result_first, result_first + n]中。n的值是last - first和result_last - result_first中较小的一个。该函数返回result - first + n。第一个版本使用<来确定顺序，第二个版本使用比较对象comp。

（5）is_sorted（C++11）
```c++
template<class ForwardIterator>
void is_sorted(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class Compare>
void is_sorted(ForwardIterator first, ForwardIterator last,
               Compare comp);
```

如果区间[first, last]是经过排序的，函数is_sorted( )将返回true，否则返回false。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（6）is_sorted_until（C++11）
```c++
template<class ForwardIterator>
ForwardIterator is_sorted_until(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class Compare>
ForwardIterator is_sorted_until(ForwardIterator first, ForwardIterator last,
               Compare comp);
```

如果区间[first, last]包含的元素少于两个，函数is_sorted_until将返回last；否则将返回迭代器it，确保区间[first, it]是经过排序的。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（7）nth_element( )
```c++
template<class RandomAccessIterator>
void nth_element(RandomAccessIterator first, RandomAccessIterator nth,
                 RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void nth_element(RandomAccessIterator first, RandomAccessIterator nth,
                 RandomAccessIterator last, Compare comp);
```

nth_element( )函数找到将[first, last)区间排序后的第n个元素，并将该元素置于第n个位置。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

2. 二分法搜索

二分法搜索组中的算法假设区间是经过排序的。这些算法只要求正向迭代器，但使用随机迭代器时，效率最高。

（1）lower_bound( )
```c++
template<class ForwardIterator>
ForwardIterator lower_bound(ForwardIterator first, ForwardIterator last,
                 const T& vlaue);

template<class ForwardIterator, class T, class Compare>
ForwardIterator lower_bound(ForwardIterator first, ForwardIterator last,
                 const T& vlaue, Compare comp);
```

lower_bound( )函数在排序后的区间[first, last)中找到第一个这样的位置，即将value插入到它前面时不会破坏顺序。它返回一个指向这个位置的迭代器。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（2）upper_bound( )
```c++
template<class ForwardIterator, class T>
ForwardIterator upper_bound(ForwardIterator first, ForwardIterator last,
                 const T& vlaue);

template<class ForwardIterator, class T, class Compare>
ForwardIterator upper_bound(ForwardIterator first, ForwardIterator last,
                 const T& vlaue, Compare comp);
```

upper_bound( )函数在排序后的区间[first, last)中找到最后一个这样的位置，即将value插入到它前面时不会破坏顺序。它返回一个指向这个位置的迭代器。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（3）equal_range( )
```c++
template<class ForwardIterator, class T>
pair<ForwardIterator, ForwardIterator> equal_range(
     ForwardIterator first, ForwardIterator last, const T& value);

template<class ForwardIterator, class T, class Compare>
pair<ForwardIterator, ForwardIterator> equal_range(
     ForwardIterator first, ForwardIterator last, const T& value,
     Compare comp);
```

equal_range( )函数在排序后的区间[first, last)区间中找到这样一个最大的子区间[it1, it2)，即将value插入到该区间的任何位置都不会破坏顺序。该函数返回一个由it1和it2组成的pair。第一个版本使用<来确定顺序，第二个版本使用比较对象comp。

（4）binary_search( )
```c++
template<class ForwardIterator, class T>
bool binary_search(ForwardIterator first, ForwardIterator last,
                   const T& value);

template<class ForwardIterator, class T, class Compare>
bool binary_search(ForwardIterator first, ForwardIterator last,
                   const T& value, Compare comp);
```

如果在排序后的区间[first, last]中找到与value等价的值，则binary_search( )函数返回true，否则返回false。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

注意：前面说过，使用<进行排序时，如果a < b和 b < a都为false，则a和b等价。对于常规数字来说，等价意味着相等；但对于只根据一个成员进行排序的结构来说，情况并非如此。因此，在确保顺序不被破坏的情况下，可插入新值的位置可能不止一个。同样，如果使用比较对象comp进行排序，等价意味着comp(a, b)和comp（b，a）都为false（这是“如果a不小于b，b也不小于a，则a与b等价”的统称）。

3. 合并

合并函数假设区间是经过排序的。

（1）merge( )
```c++
template<class InputIterator1, class InputIterator2,
         class OutputIterator>
OutputIterator merge(InputIterator1 first1, InputIterator1 last1,
                     InputIterator2 first2, InputIterator2 last2,
                     OutputIterator result);

template<class InputIterator1, class InputIterator2,
         class OutputIterator, class Compare>
OutputIterator merge(InputIterator1 first1, InputIterator1 last1,
                     InputIterator2 first2, InputIterator2 last2,
                     OutputIterator result, Compare comp);
```

merge( )函数将排序后的区间[first1, last1] 中的元素与排序后的区间[first2, last2] 中的元素进行合并，并将结果放到从result开始的区间中。目标区间不能与被合并的任何一个区间重叠。在两个区间中发现了等价元素时，第一个区间中的元素将位于第二个区间中的元素前面。返回值是合并的区间的超尾迭代器。第一个版本使用<来确定顺序，第二个版本使用比较对象comp。

（2）inplace_merge( )
```c++
template<class BidirectionalIterator>
void inplace_merge(BidirectionalIterator first,
                   BidirectionalIterator middle, BidirectionalIterator last);

template<class BidirectionalIterator, class Compare>
void inplace_merge(BidirectionalIterator first,
                   BidirectionalIterator middle, BidirectionalIterator last,
                   Compare comp);
```

inplace_merge( )函数将两个连续的、排序后的区间—[first, middle]和[middle, last] —合并为一个经过排序的序列，并将其存储在[first, last]区间中。第一个区间中的元素将位于第二个区间中的等价元素之前。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

4. 使用集合

集合操作可用于所有排序后的序列，包括集合（set）和多集合（multiset）。对于存储一个值的多个实例的容器（如multiset）来说，定义是广义的。对于两个多集合的并集，将包含较大数目的元素实例，而交集将包含较小数目的元素实例。例如，假设多集合A包含了字符串“apple”7次，多集合B包含该字符串4次。则A和B的并集将包含7个“apple”实例，它们的交集将包含4个实例。

（1）includes( )
```c++
template<class InputIterator1, class InputIterator2>
bool includes(InputIterator1 first1, InputIterator1 last1,
              InputIterator2 first2, InputIterator2 last2,);

template<class InputIterator1, class InputIterator2, class Compare>
bool includes(InputIterator1 first1, InputIterator1 last1,
              InputIterator2 first2, InputIterator2 last2, Compare comp);
```

如果[first2, last2)区间中的每一个元素在[first1, last1)区间中都可以找到，则includes( )函数返回true，否则返回false。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（2）set_union( )
```c++
template<class InputIterator1, class InputIterator2,
         class OutputIterator>
OutputIterator set_union(InputIterator1 first1, InputIterator1 last1,
                         InputIterator2 first2, InputIterator2 last2,
                         OutputIterator result);

template<class InputIterator1, class InputIterator2,
         class OutputIterator, class Compare>
OutputIterator set_union(InputIterator1 first1, InputIterator1 last1,
                         InputIterator2 first2, InputIterator2 last2,
                         OutputIterator result, Compare comp);
```

set_union( )函数构造一个由[first1, last1]区间和[first2, last2] 区间组合而成的集合，并将结果复制到result指定的位置。得到的区间不能与原来的任何一个区间重叠。该函数返回构造的区间的超尾迭代器。并集包含在任何一个集合（或两个集合）中出现的所有元素。第一个版本使用 < 来确定顺序，而第二个版本使用比较对象comp。

（3）set_intersection( )
```c++
template<class InputIterator1, class InputIterator2,
         class OutputIterator>
OutputIterator set_intersection(InputIterator1 first1, InputIterator1 last1,
                                InputIterator2 first2, InputIterator2 last2,
                                OutputIterator result);

template<class InputIterator1, class InputIterator2,
         class OutputIterator, class Compare>
OutputIterator set_intersection(InputIterator1 first1, InputIterator1 last1,
                                InputIterator2 first2, InputIterator2 last2,
                                OutputIterator result, Compare comp);
```

set_intersection( )函数构造[first1, last1)区间和[first2, last2)区间的交集，并将结果复制到result指定的位置。得到的区间不能与原来的任何一个区间重叠。该函数返回构造的区间的超尾迭代器。交集包含两个集合中共有的元素。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（4）set_difference( )
```c++
template<class InputIterator1, class InputIterator2,
         class OutputIterator>
OutputIterator set_difference(InputIterator1 first1, InputIterator1 last1,
                              InputIterator2 first2, InputIterator2 last2,
                              OutputIterator result);

template<class InputIterator1, class InputIterator2,
         class OutputIterator, class Compare>
OutputIterator set_difference(InputIterator1 first1, InputIterator1 last1,
                              InputIterator2 first2, InputIterator2 last2,
                              OutputIterator result, Compare comp);
```

set_difference( )函数构造[first1, last1)区间与[first2, last2)区间的差集，并将结果复制到result指定的位置。得到的区间不能与原来的任何一个区间重叠。该函数返回构造的区间的超尾迭代器。差集包含出现在第一个集合中，但不出现在第二个集合中的所有元素。第一个版本使用<来确定顺序，而第二个版本使用比较对象comp。

（5）set_symmetric_difference( )
```c++
template<class InputIterator1, class InputIterator2,
         class OutputIterator>
OutputIterator set_symmetric_difference(
                              InputIterator1 first1, InputIterator1 last1,
                              InputIterator2 first2, InputIterator2 last2,
                              OutputIterator result);

template<class InputIterator1, class InputIterator2,
         class OutputIterator, class Compare>
OutputIterator set_symmetric_difference(
                              InputIterator1 first1, InputIterator1 last1,
                              InputIterator2 first2, InputIterator2 last2,
                              OutputIterator result, Compare comp);
```

set_symmetric_difference( )函数构造[first1, last1)区间和[first2, last2)区间的对称（symmetric）差集，并将结果复制到result指定的位置。得到的区间不能与原来的任何一个区间重叠。该函数返回构造的区间的超尾迭代器。对称差集包含出现在第一个集合中，但不出现在第二个集合中，或者出现在第二个集合中，但不出现在第一个集合中的所有元素。第一个版本使用<来确定顺序，第二个版本使用比较对象comp。

5. 使用堆

堆（heap）是一种常用的数据形式，具有这样特征：第一个元素是最大的。每当第一个元素被删除或添加了新元素时，堆都可能需要重新排列，以确保这一特征。设计堆是为了提高这两种操作的效率。

（1）make_heap( )
```c++
template<class RandomAccessIterator>
void make_heap(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void make_heap(RandomAccessIterator first, RandomAccessIterator last,
               Compare comp);
```

make_heap( )函数将[first, last)区间构造成一个堆。第一个版本使用 < 来确定顺序，而第二个版本使用comp比较对象。

（2）push_heap( )
```c++
template<class RandomAccessIterator>
void push_heap(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void push_heap(RandomAccessIterator first, RandomAccessIterator last,
               Compare comp);
```

push_heap( )函数假设[first, last – 1)区间是一个有效的堆，并将last - 1位置（即被假设为有效堆的区间后面的一个位置）上的值添加到堆中，使[first, last)区间成为一个有效堆。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（3）pop_heap( )
```c++
template<class RandomAccessIterator>
void pop_heap(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void pop_heap(RandomAccessIterator first, RandomAccessIterator last,
               Compare comp);
```

pop_heap( )函数假设[first, last)区间是一个有效堆，并将位置last - 1处的值与first处的值进行交换，使[first, last – 1]区间成为一个有效堆。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（4）sort_heap( )
```c++
template<class RandomAccessIterator>
void sort_heap(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void sort_heap(RandomAccessIterator first, RandomAccessIterator last,
               Compare comp);
```

sort_heap( )函数假设[first, last)区间是一个有效堆，并对其进行排序。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（5）is_heap( )（C++11）
```c++
template<class RandomAccessIterator>
void is_heap(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
void is_heap(RandomAccessIterator first, RandomAccessIterator last,
               Compare comp);
```

如果区间[first, last]是一个有效的堆，函数is_heap( )将返回true，否则返回false。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（6）is_heap_until( )（C++11）
```c++
template<class RandomAccessIterator>
RandomAccessIterator is_heap_until(RandomAccessIterator first, RandomAccessIterator last);

template<class RandomAccessIterator, class Compare>
RandomAccessIterator is_heap_until(RandomAccessIterator first, RandomAccessIterator last,
               Compare comp);
```

如果区间[first, last)包含的元素少于两个，则返回last；否则返回迭代器it，而区间[first, it)是一个有效的堆。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

6. 查找最小和最大值

最小函数和最大函数返回两个值或值序列中的最小值和最大值。

（1）min( )
```c++
template<class T> const T& min(const T& a, const T& b);

template<class T, class Compare>
const T& min(const T& a, const T& b, Compare comp);
```

这些版本的min( )函数返回两个值中较小一个；如果这两个值相等，则返回第一个值。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。
```c++
template<class T> T min(initializer_list<T> t);

template<class T, class Compare>
T min(initializer_list<T> t, Compare comp);
```

这些版本的min( )函数是C++11新增的，它返回初始化列表t中最小的值。如果有多个相等的值且最小，则返回第一个。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（2）max( )
```c++
template<class T> const T& max(const T& a, const T& b);

template<class T, class Compare>
const T& max(const T& a, const T& b, Compare comp);
```

这些版本的max( ) 函数返回这两个值中较大的一个；如果这两个值相等，则返回第一个值。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。
```c++
template<class T> T max(initializer_list<T> t);

template<class T, class Compare>
T max(initializer_list<T> t, Compare comp);
```

这些版本的max( )函数是C++11新增的，它返回初始化列表t中最大的值。如果有多个相等的值且最大，则返回第一个。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（3）minmax( )（C++11）
```c++
template<class T>
pair<const T&, const T&> minmax(const T& a, const T& b);

template<class T, class Compare>
pair<const T&, const T&> minmax(const T& a, const T& b, Compare comp);
```

如果b小于a，这些版本的minmax( )函数返回pair(b, a)，否则返回pair(a, b)。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。
```c++
template<class T> pair<T, T> minmax(initializer_list<T> t);

template<class T, class Compare>
pair<T, T> minmax(initializer_list<T> t, Compare comp);
```

这些版本的minmax( )函数返回初始化列表t中最小元素和最大元素的拷贝。如果有多个最小的元素，则返回其中的第一个；如果有多个最大的元素，则返回其中的最后一个。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（4）min_element( )
```c++
template<class ForwardIterator>
ForwardIterator min_element(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class Compare>
ForwardIterator min_element(ForwardIterator firstm ForwardIterator last,
                            Compare comp);
```

min_element( )函数返回这样一个迭代器，该迭代器指向[first, last)区间中第一个最小的元素。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（5）max_element( )
```c++
template<class ForwardIterator>
ForwardIterator max_element(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class Compare>
ForwardIterator max_element(ForwardIterator firstm ForwardIterator last,
                            Compare comp);
```

max_element( )函数返回这样一个迭代器，该迭代器指向[first, last]区间中第一个最大的元素。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（6）minmax_element( )（C++11）
```c++
template<class ForwardIterator>
pair<ForwardIterator, ForwardIterator>
minmax_element(ForwardIterator first, ForwardIterator last);

template<class ForwardIterator, class Compare>
pair<ForwardIterator, ForwardIterator>
minmax_element(ForwardIterator first, ForwardIterator last,
               Compare comp);
```

函数minmax_element( )返回一个pair对象，其中包含两个迭代器，分别指向区间[first, last)中最小和最大的元素。第一个版本使用<来确定顺序，而第二个版本使用comp比较对象。

（7）lexicographical_compare( )
```c++
template<class InputIterator1, class InputIterator2>
bool lexicographical_compare(
     InputIterator1 first1, InputIterator1 last1,
     InputIterator2 first2, InputIterator2 last2);

template<class InputIterator1, class InputIterator2, class Compare>
bool lexicographical_compare(
     InputIterator1 first1, InputIterator1 last1,
     InputIterator2 first2, InputIterator2 last2,
     Compare comp);
```

如果[first1, last1]区间中的元素序列按字典顺序小于[first2, last2]区间中的元素序列，则lexicographical_compare( )函数返回true，否则返回false。字典比较将两个序列的第一个元素进行比较，即对 * first1和 * first2进行比较。如果 * first1小于 * first2，则该函数返回true；如果 * first2小于 * first1，则返回fasle；如果相等，则继续比较两个序列中的下一个元素。直到对应的元素不相等或到达了某个序列的结尾，比较才停止。如果在到达某个序列的结尾时，这两个序列仍然是等价的，则较短的序列较小。如果两个序列等价，且长度相等，则任何一个序列都不小于另一个序列，因此函数将返回false。第一个版本使用<来比较元素，而第二个版本使用comp比较对象。字典比较是按字母顺序比较的统称。

7. 排列组合

序列的排列组合是对元素重新排序。例如，由3个元素组成的序列有6种可能的排列方式，因为对于第一个位置，有3种选择；给第一个位置选定元素后，第二个位置有两种选择；第三个位置有1种选择。例如，数字1、2和3的6种排列如下：
```c++
123 132 213 232 312 321
```

通常，由n个元素组成的序列有n*(n−1)*...*1或n!种排列。

排列函数假设按字典顺序排列各种可能的排列组合，就像前一个例子中的6种排列那样。这意味着，通常，在每个排列之前和之后都有一个特定的排列。例如，213在231之前，312在231之后。然而，第一个排列（如示例中的123）前面没有其他排列，而最后一个排列（321）后面没有其他排列。

（1）next_permutation( )
```c++
template<class BidirectionalIterator>
bool next_permutation(BidirectionalIterator first, BidirectionalIterator last);

template<class BidirectionalIterator, class Compare>
bool next_permutation(BidirectionalIterator first, BidirectionalIterator last,
                            Compare comp);
```

next_permutation( )函数将[first, last]区间中的序列转换为字典顺序的下一个排列。如果下一个排列存在，则该函数返回true；如果下一个排列不存在（即区间中包含的是字典顺序的最后一个排列），则该函数返回false，并将区间转换为字典顺序的第一个排列。第一个版本使用<来确定顺序，而第二个版本则使用comp比较对象。

（2）prev_permutation( )
```c++
template<class BidirectionalIterator>
bool prev_permutation(BidirectionalIterator first, BidirectionalIterator last);

template<class BidirectionalIterator, class Compare>
bool prev_permutation(BidirectionalIterator first, BidirectionalIterator last,
                            Compare comp);
```

previous_permutation( )函数将[first, last] 区间中的序列转换为字典顺序的前一个序列。如果前一个排列存在，则该函数返回true；如果前一个序列不存在（即区间包含的是字典顺序的第一个排列），则该函数返回false，并将该区间转换为字典顺序的最后一个排列。第一个版本使用<来确定顺序，而第二个版本则使用comp比较对象。

### G.5.4 数值运算
表G.16对数值运算进行了总结，这些操作是由头文件numeric描述的。其中没有列出参数，而重载函数也只列出了一次。每一个函数都有一个使用<对元素进行排序的版本和一个使用比较函数对象对元素进行排序的版本。表后做了更详细的说明，其中包括原型。因此，可以浏览该表，以了解函数的功能；如果对某个函数非常感兴趣，则可以了解其细节。

**表G.16 数值运算**

| 函 数 | 描 述 |
| :--- | :--- |
| accumulate( ) | 计算区间中的值的总和 |
| inner_product( ) | 计算2个区间的内部乘积 |
| partial_sum( ) | 将使用一个区间计算得到的小计复制到另一个区间中 |
| adjacent_difference( ) | 将使用一个区间的元素计算得到的相邻差集复制到另一个区间中 |
| iota( ) | 将使用运算符++生成的一系列相邻的值赋给一个区间中的元素，这是C++11新增的 |

1. accumulate( )
```c++
template<class InputIterator, class T>
T accumulate(InputIterator first, InputIterator last, T init);

template<class InputIterator, class T, class BinaryOperation>
T accumulate(InputIterator first, InputIterator last, T init,
             BinaryOperation binary_op);
```

accumulate( )函数将acc的值初始化为init，然后按顺序对[first, last]区间中的每一个迭代器i执行acc = acc + * i（第一个版本）或acc = binary_op(acc, *i)（第二个版本）。然后返回acc的值。

2. inner_product( )
```c++
template<class InputIterator1, class InputIterator2, class T>
T inner_product(InputIterator1 first1, InputIterator1 last1,
                InputIterator2 first2, T init);

template<class InputIterator1, class InputIterator2, class T,
         class BinaryOperation1, class BinaryOperation2>
T inner_product(InputIterator1 first1, InputIterator1 last1,
                InputIterator2 first2, T init,
                BinaryOperation1 binary_op1, BinaryOperation2 binary_op2);
```

inner_product( )函数将acc的值初始化为init，然后按顺序对[first1, last1]区间中的每一个迭代器i和[first2, first2 + (last1−first1)]区间中对应的迭代器j执行acc = * i * * j（第一个版本）或acc = binary_op(*i, *j)（第二个版本）。也就是说，该函数对每个序列的第一个元素进行计算，得到一个值，然后对每个序列中的第二个元素进行计算，得到另一个值，依此类推，直到到达第一个序列的结尾（因此，第二个序列至少应同第一个序列一样长）。然后，函数返回acc的值。

3. partial_sum( )
```c++
template<class InputIterator, class OutputIterator>
OutputIterator partial_sum(InputIterator first, InputIterator last,
                           OutputIterator result);

template<class InputIterator, class OutputIterator, class BinaryOperation>
OutputIterator partial_sum(InputIterator first, InputIterator last,
                           OutputIterator result,
                           BinaryOperation binary_op);
```

partial_sum( )函数将 * first赋给 * result，将 * first + * (first + 1)赋给 * (result + 1)（第一个版本），或者将binary_op( * first, * (first + 1))赋给 * (result + 1)（第二个版本），依此类推。也就是说，从result开始的序列的第n个元素将包含从first开始的序列的前n个元素的总和（或binary_op的等价物）。该函数返回结果的超尾迭代器。该算法允许result等于first，也就是说，如果需要，该算法允许使用结果覆盖原来的序列。

4. adjacent_difference( )
```c++
template<class InputIterator, class OutputIterator>
OutputIterator adjacent_difference(InputIterator first, InputIterator last,
                           OutputIterator result);

template<class InputIterator, class OutputIterator, class BinaryOperation>
OutputIterator adjacent_difference(InputIterator first, InputIterator last,
                           OutputIterator result,
                           BinaryOperation binary_op);
```

adjacent_difference( )函数将 * first赋给result( * result = * first)。目标区间中随后的位置将被赋值为源区间中相邻位置的差集（或binary_op等价物）。也就是说，目标区间的下一个位置(result +1)将被赋值为*(first + 1) - * first（第一个版本）或binary_op(*(first + 1), * first)（第二个版本），依此类推。该函数返回结果的超尾迭代器。该算法允许result等于first，也就是说，如果需要，该算法允许结果覆盖原来的序列。

5. iota( )（C++11）
```c++
template<class ForwardIterator, class T>
void iota(ForwardIterator first, ForwardIterator last, T value);
```

函数iota( )将value赋给*first，再将value递增（就像执行运算++value），并将结果赋给下一个元素，依次类推，直到最后一个元素。










