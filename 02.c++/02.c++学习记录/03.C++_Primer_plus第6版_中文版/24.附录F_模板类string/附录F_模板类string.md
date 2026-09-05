# 附录F 模板类string
本附录的技术性较强，但如果您只想了解模板类string的功能，可以将重点放在对各种string类方法的描述上。

string类是基于下述模板定义的：
```c++
template<class charT, class traits = char_traits<charT>, class Allocator = allocator<charT>>
class basic_string { ... };
```

其中，chatT是存储在字符串中的类型；traits参数是一个类，它定义了类型要被表示为字符串时，所必须具备的特征。例如，它必须有length( )方法，该方法返回被表示为charT数组的字符串的长度。这种数组结尾用charT(0)值（广义的空值字符）表示。（表达式charT(0)将0转换为charT类型。它可以像类型为char时那样为零，也可以是charT的一个构造函数创建的对象）。这个类还包含用于对值进行比较等操作的方法。Allocator参数是用于处理字符串内存分配的类。默认的allocator<char>模板按标准方式使用new和delete。

有4种预定义的具体化：
```c++
typedef basic_string<char> string;
typedef basic_string<char16_t> u16string;
typedef basic_string<char32_t> u32string;
typedef basic_string<wchar_t> wstring;
```

上述具体化又使用下面的具体化：
```c++
char_traits<char>
allocator<char>
char_traits<char16_t>
allocator<char16_t>
char_traits<char32_t>
allocator<char32_t>
char_traits<wchar_t>
allocator<wchar_t>
```

除char和wchar_t外，还可以通过定义traits类和使用basic_string模板来为其他一些类型创建一个string类。

## F.1 13种类型和一个常量
模板basic_string定义了几种类型，供以后定义方法时使用：
```c++
typedef traits                                traits_type;
typedef typename traits::char_type            value_type;
typedef Allocator                             allocator_type;
typedef typename Allocator::size_type         size_type
typedef typename Allocator::difference_type   difference_type;
typedef typename Allocator::reference         reference;
typedef typename Allocator::const_reference   const_reference;
typedef typename Allocator::pointer           pointer;
typedef typename Allocator::const_pointer     const_pointer;
```

traits是对应于特定类型（如char_traits<char>）的模板参数；traits_type将成为该特定类型的typedef。下述表示法意味着char_type是traits表示的类中定义的一个类型名：
```c++
typedef typename traits::char_type            value_type;
```

关键字typename告诉编译器，表达式trait::char_type是一种类型。例如，对于string具体化，value_type为char。

size_type与size_of的用法相似，只是它根据存储的类型返回字符串的长度。对于string具体化，将根据char返回字符串的长度，在这种情况下，size_type与size_of等效。size_type是一种无符号类型。

differrence_type用于度量字符串中两个元素之间的距离（单位为元素的长度）。通常，它是底层类型size_type有符号版本。

对于char具体化来说，pointer的类型为char *，而reference的类型为char &类型。然而，如果要为自己设计的类型创建具体化，则这些类型（pointer和reference）可以指向类，与基本指针和引用有相同的特征。

为将标准模板库（STL）算法用于字符串，该模板定义了一些迭代器类型：
```c++
typedef (models random access iterator)         iterator;
typedef (models random access iterator)         const_iterator;
typedef std::reverse_iterator<iterator>         reverse_iterator;
typedef std::reverse_iterator<const_iterator>   const_reverse_iterator;
```

该模板还定义了一个静态常量：
```c++
static const size_type npos = -1;
```

由于size_type是无符号的，因此将-1赋给npos相当于将最大的无符号值赋给它，这个值比可能的最大数组索引大1。

## F.2 数据信息、构造函数及其他
可以根据其效果来描述构造函数。由于类的私有部分可能依赖于实现，因此可根据公用接口中可用的数据来描述这些效果。表F.1列出了一些方法，它们的返回值可用来描述构造函数和其他方法的效果。注意，其中的大部分术语来自STL。

**表F.1 一些string数据方法**

| 方 法 | 返 回 值 |
| :--- | :--- |
| begin( ) | 指向字符串第一个字符的迭代器 |
| cbegin( ) | 一个const_iterator，指向字符串中的第一个字符（C++11） |
| end( ) | 为超尾值的迭代器 |
| cend( ) | 为超尾值的const_iterator（C++11） |
| rbegin( ) | 为超尾值的反转迭代器 |
| crbegin( ) | 为超尾值的反转const_iterator（C++11） |
| rend( ) | 指向第一个字符的反转迭代器 |
| crend( ) | 指向第一个字符的反转const_iterator（C++11） |
| size( ) | 字符串中的元素数，等于begin( )到end( )之间的距离 |
| length( ) | 与size( )相同 |
| capacity( ) | 给字符串分配的元素数。这可能大于实际的字符数，capacity( ) – size( )的值表示在字符串末尾附加多少字符后需要分配更多的内存 |
| max_size( ) | 字符串的最大长度 |
| data( ) | 一个指向数组第一个元素的const charT指针，其第一个size( )元素等于this控制的字符串中对应的元素，其下一个元素为charT类型的charT(0)字符（字符串末尾标记）。当string对象本身被修改后，该指针可能无效 |
| c_str( ) | 一个指向数组第一个元素的const charT指针，其第一个size( )元素等于this控制的字符串中对应的元素，其下一个元素是charT类型的charT（0）字符（字符串尾标识）。当string对象本身被修改后，该指针可能无效 |
| get_allocator( ) | 用于为字符串object分配内存的allocator对象的副本 |

请注意begin( )、rend( )、data( )和c_str( )之间的差别。它们都与字符串的第一个字符相关，但相关的方式不同。begin( )和rend( )方法返回一个迭代器，正如第16章讨论的，这是一种广义指针。具体地说，begin( )返回一个正向迭代器模型，而rend( )返回反转迭代器的一个副本。这两种方法都引用了string对象管理的字符串（由于string类使用动态内存分配，因此实际的string内容不一定位于对象中，因此，我们使用术语“管理”来描述对象和字符串之间的关系）。可以将返回迭代器的方法用于基于迭代器的STL算法中。例如，可以使用STL reverse( )函数来反转字符串的内容：
```c++
string word;
cin >> word;
reverse(word.begin(), word.end());
```

而data( )和c_str( )方法返回常规指针。另外，返回的指针将指向存储字符串字符的数组的第一个元素。该数组可能（但不一定）是string对象管理的字符串的副本（string对象采用的内部表示可以是数组，但不一定非得是数组）。由于返回的指针可能指向原始数据，而原始数据是const，因此不能用它们来修改数据。另外，当字符串被修改后，将不能保证这些指针是有效的，这表明它们可能指向原始数据。data( )和c_str( )的区别在于，c_str( )指向的数组以空值字符（或与之等价的其他字符）结束，而data( )只是确保实际的字符串字符是存在的。因此，c_str( )方法期望接受一个C-风格字符串参数：
```c++
string file("tofu.man");
ofstream outFile(file.c_str());
```

同样，data( )和size( )可用作这种函数的参数，即接受指向数组元素的指针和表示要处理的元素数目的值：
```c++
string vampire("Do not stake me, oh my darling!");
int vlad = byte_check(vampire.data(), vampire.size());
```

C++实现可能将string对象的字符串表示为动态分配的C-风格字符串，并使用char*指针来实现正向迭代器。在这种情况下，实现可能让begin( )、data( )和c_str( )都返回同样的指针，但返回指向3个不同的数据对象的引用也是合法的（虽然更复杂）。

在C++11中，模板类basic_string有11个构造函数（在C++98中只有6个）和一个析构函数：
```c++
explicit basic_string(const Allocator& a = Allocator());
basic_string(const charT* s, const Allocator& a = Allocator());
basic_string(const charT* s, size_type n, const Allocator& a = Allocator());
basic_string(const basic_string& str);
basic_string(const basic_string& str, const Allocator&);
basic_string(const basic_string& str, size_type pos,
        size_type n = npos, const Allocator& a = Allocator());
basic_string(basic_string&& str) noexcept;
basic_string(const basic_string&& str, const Allocator&);
basic_string(size_type n, charT c, const Allocator& a = Allocator());
template<class InputIterator>
basic_string(InputIterator begin, InputIterator end,
    const Allocator& a = Allocator());
basic_string(initializer_list<charT>, const Allocator& a = Allocator());
~basic_string();
```

有些新增的构造函数以不同的方式处理参数。例如，C++98包含如下复制构造函数：
```c++
basic_string(const basic_string& str, size_type pos = 0,
    size_type n = npos, const Allocator& a = Allocator());
```

而C++11用三个构造函数取代了它—上述列表中的第2～4个，这提高了编码效率。真正新增的只有移动构造函数（使用右值引用的构造函数，这在第18章讨论过）以及使用initializer_list参数的构造函数。

注意到大多数构造函数构造函数都有一个下面这样的参数：
```c++
const Allocator& a = Allocator()
```

Allocator是用于管理内存的allocator类的模板参数名；Allocator( )是这个类的默认构造函数。因此，在默认情况下，构造函数将使用allocator对象的默认版本，但它们使得能够选择使用allocator对象的其他版本。下面分别介绍这些构造函数。

### F.2.1 默认构造函数
默认构造函数的原型如下：
```c++
explicit basic_string(const Allocator& a = Allocator());
```

通常，接受allocator类的默认参数，并使用该构造函数来创建空字符串：
```c++
string bean;
wstring theory;
```

调用该默认构造函数后，将存在下面的关系：

* data( )方法返回一个非空指针，可以将该指针加上0；
* size( )方法返回0；
* capacity( )的返回值不确定。

将data( )返回的值赋给指针str后，第一个条件意味着str + 0是有效的。

### F.2.2 使用C-风格字符串的构造函数
使用C-风格字符串的构造函数让您能够将string对象初始化为一个C-风格字符串；从更普遍的意义上看，它使得能够将charT具体化初始化为一个charT数组：
```c++
basic_string(const charT* s, const Allocator& a = Allocator());
```

为确定要复制的字符数，该构造函数将traits::length( )方法用于s指向的数组（s不能为空指针）。例如，下面的语句使用指定的字符串来初始化toast对象：
```c++
string toast("Here's looking at you, kid.");
```

char类型的traits::length( )方法将使用空值字符来确定要复制多少个字符。

该构造函数被调用后，将存在下面的关系：

* data( )方法返回一个指针，该指针指向数组s的一个副本的第一个元素；
* size( )方法返回的值等于trains::length( )的值；
* capacity( )方法返回一个至少等于size( )的值。

### F.2.3 使用部分C-风格字符串的构造函数
使用部分C-风格字符串的构造函数让您能够使用C-风格字符串的一部分来初始化string对象；从更广泛的意义上说，该构造函数使得能够使用charT数组的一部分来初始化charT具体化：
```c++
basic_string(const charT* s, size_type n, const Allocator& a = Allocator());
```

该构造函数将s指向的数组中的n个字符复制到构造的对象中。请注意，如果s包含的字符数少于n，则复制过程将不会停止。如果n大于s的长度，该构造函数将把字符串后面的内存内容解释为charT类型的数据。

该构造函数要求s不能是空值指针，同时n < npos（npos是一个静态类常量，它是字符串可能包含的最大元素数目）。如果n等于npos，该构造函数将引发一个out_of_range异常（由于n的类型为size_type，而npos是size_type的最大值，因此n不能大于npos）；否则，在该构造函数被调用后，将存在下面的关系：

* data( )方法返回一个指针，该指针指向数组s的副本的第一个元素；
* size( )方法返回n；
* capacity( )方法返回一个至少等于size( )的值。

### F.2.4 使用左值引用的构造函数
复制构造函数类似于下面这样：
```c++
basic_string(const basic_string& str);
```

它使用一个string参数初始化一个新的string对象：
```c++
string mel("I'm ok!");
string ida(mel);
```

其中，ida将是mel管理的字符串副本。

下一个构造函数要求您指定一个分配器：
```c++
basic_string(const basic_string& str, const Allocator&);
```

调用这两个构造函数中的任何一个后，将存在如下关系：

* data( )方法返回一个指针，该指针指向分配的数组副本，该数组的第一个元素是str.data( )指向的；
* size( )方法返回str.size()的值；
* capacity( )方法返回一个至少等于size( )的值。

再下一个构造函数让您能够指定多项内容：
```c++
basic_string(const basic_string& str, size_type pos,
        size_type n = npos, const Allocator& a = Allocator());
```

第二个参数（pos）指定了源字符串中的位置，将从这个位置开始进行复制：
```c++
string att("Telephone home.");
string et(att, 4);
```

位置编号从0开始，因此，位置4是字符p。所以，et被初始化为“phone home”。

第3个参数n是可选的，它指定要复制的最大字符数目，因此下面的语句将pt初始化为字符串“phone”：
```c++
string att("Telephone home.");
string pt(att, 4, 5);
```

然而，该构造函数不能跨越源字符串的结尾，例如，下面的语句将在复制句点后停止：
```c++
string pt(att, 4, 200);
```

因此，该构造函数实际复制的字符数量等于n和str.size( )-pos中较小的一个。

该构造函数要求pos不大于str.size( )，也就是说，被复制的初始位置必须位于源字符串中。如果情况并非如此，该构造函数将引发out_of_range异常；否则，该构造函数被调用后，copy_len将是n和str.size( )-pos中较小的一个，并存在下面的关系：

* data( )方法返回一个指向字符串的指针，该字符串包含copy_len个元素，这些元素是从str的pos位置开始复制而得到的；
* size( )方法返回copy_len；
* capacity( )方法返回一个不小于size( )的值。

### F.2.5 使用右值引用的构造函数（C++11）
C++11给string类添加了移动语义。正如第18章介绍的，这意味着添加一个移动构造函数，它使用右值引用而不是左值引用：
```c++
basic_string(basic_string&& str) noexcept;
```

在实参为临时对象时将调用这个构造函数：
```c++
string one("din");        // C-style string constructor
string two(one);          // copy constructor - one is an lvalue
string three(one+two);    // move constructor, sum is an rvalue
```

正如第18章讨论的，three将获取operator + ()创建的对象的所有权，而不是将该对象复制给three，再销毁原始对象。

第二个使用右值引用的构造函数让您能够指定分配器：
```c++
basic_string(const basic_string&& str, const Allocator&);
```

调用这两个构造函数中的任何一个后，将存在如下关系：

* data( )方法返回一个指针，该指针指向分配的数组副本，该数组的第一个元素是str.data( )指向的；
* size( )方法返回str.size()的值；
* capacity( )方法返回一个至少等于size( )的值。

### F.2.6 使用一个字符的n个副本的构造函数
使用一个字符的n个副本的构造函数创建一个由n个c组成的string对象：
```c++
basic_string(size_type n, charT c, const Allocator& a = Allocator());
```

该构造函数要求 n < npos。如果n等于npos，该构造函数将引发out_of_range异常；否则，该构造函数被调用后，将存在下面的关系：

* data( )方法返回一个指向字符串第一个元素的指针，该字符串由n个元素组成，其中每个元素的值都为c；
* size( )方法返回n；
* capacity( )方法返回不小于size( )的值。

### F.2.7 使用区间的构造函数
使用区间的构造函数使用一个用迭代器定义的、STL-风格的区间：
```c++
template<class InputIterator>
basic_string(InputIterator begin, InputIterator end,
    const Allocator& a = Allocator());
```

begin迭代器指向源字符串中要复制的第一个元素，end指向要复制的最后一个元素的后面。

这种构造函数可用于数组、字符串或STL容器：
```c++
char cole[40] = "Old King Cole was a merry old soul.";
string title(cole + 4, cole + 8);
vector<char> input;
char ch;
while (cin.get(ch) && ch != '\n')
    input.push_back(ch);
string str_input(input.begin(), input.end());
```

在第一种用法中，InputIterator的类型为const char *；在第二种用法中，InputIterator的类型为vector<char>::iterator。

调用该构造函数后，将存在下面的关系：

* data( )方法返回一个指向字符串的第一个元素的指针，该字符串是通过复制区间[begin，end）中的元素得到的；
* size( )方法返回begin到end之间的距离（度量距离时，使用的单位为对迭代器解除引用得到的数据类型的长度）；
* capacity( )方法返回一个不小于size( )的值。

### F.2.8 使用初始化列表的构造函数（C++11）
这个构造函数接受一个initializer_list<charT>参数：
```c++
basic_string(initializer_list<charT> i1, const Allocator& a = Allocator());
```

可将一个用大括号括起的字符列表作为参数：
```c++
string slow({'s', 'n', 'a', 'i', 'l'});
```

这并非初始化string的最方便方式，但让string的接口类似于STL容器类。

initializer_list类包含成员函数begin( )和end( )，调用该构造函数的影响与调用使用区间的构造函数相同：
```c++
basic_string(i1.begin(), i1.end(), a);
```

### F.2.9 内存杂记
有些方法用于处理内存，如清除内存的内容、调整字符串长度或容量。表F.2列出了一些与内存相关的方法。

**表F.2 一些与内存有关的方法**

| 方 法 | 作 用 |
| :--- | :--- |
| void resize(size_type n) | 如果n>npos，将引发out_of_range异常；否则，将字符串的长度改为n，如果n<size( )，则截短字符串，如果n>size( )，则使用charT(0)中的字符填充字符串 |
| void resize(size_type n, charT c) | 如果n>npos，将引发out_of_range异常；否则，将字符串长度改为n，如果n<size( )，则截短字符串，如果n>size( )，则使用字符c填充字符串 |
| void reserve(size_type res_arg = 0) | 将capacity( )设置为大于或等于res_arg。由于这将重新分配字符串，因此以前的引用、迭代器和指针将无效 |
| void shrink_to_fit( ) | 请求让capacity( )的值与size( )相同，这是C++11新增的 |
| void clear( ) noexcept | 删除字符串中所有的字符 |
| bool empty( )const noexcept | 如果size( )==0，则返回true |

## F.3 字符串存取
有4种方法可以访问各个字符，其中两种方法使用[ ]运算符，另外两种方法使用at( )方法：
```c++
reference operator[](size_type pos);
const_reference operator[](size_type pos) const;
reference at(size_type n);
const_reference at(size_type n) const;
```

第一个operator 方法使得能够使用数组表示法来访问字符串的元素，可用于检索或更改值。第二个operator 方法可用于const对象，但只能用于检索值：
```c++
string word("tack");
cout << word[0];    // display the t
word[3] = 't';      // overwrite the k with a t
const ward("garlic");
cout << ward[2];    // display the r
```

at( )方法提供了相似的访问功能，只是索引是通过函数参数提供的：
```c++
string word("tack");
cout << word.at(0);   // display the t
```

差别在于（除语法差别外）：at( )方法执行边界检查，如果pos>=size( )，将引发out_of_range异常。pos的类型为size_type，是无符号的，因此pos的值不能为负；而operator 方法不进行边界检查，因此，如果pos>=size( )，则其行为将是不确定的（如果pos= =size( )，const版本将返回空值字符的等价物）。

因此，可以在安全性（使用at( )检测异常）和执行速度（使用数组表示）之间进行选择。

还有一个这样的函数，它返回原始字符串的子字符串：
```c++
basic_string substr(size_type pos = 0, size_type n = npos) const;
```

它返回一个字符串—这是从pos开始，复制n个字符（或到字符串尾部）得到的。例如，下面的代码将pet初始化为“donkey”：
```c++
string message("Maybe the donkey will learn to sing.");
string pet(message.substr(10, 6));
```

C++11新增了如下四个存取方法：
```c++
const charT& front() const;
charT& front();
const charT& back() const;
charT& back();
```

其中front( )方法访问string的第一个元素，相当于operator[] (0)；back( )方法访问string的最后一个元素，相当于operator[] (size( ) - 1)。

## F.4 基本赋值
在C++11中，有5个重载的赋值方法，在C++98的基础上增加了两个：
```c++
basic_string& operator=(const basic_string& str);
basic_string& operator=(const charT* s);
basic_string& operator=(charT c);
basic_string& operator=(basic_string&& str) noexcept;   // C++11
basic_string& operator=(initializer_list<charT>);       // C++11
```

第一个方法将一个string对象赋给另一个；第二个方法将C-风格字符串赋给string对象；第三个方法将一个字符赋给string对象；第四个方法使用移动语义，将一个右值string对象赋给一个string对象；第五个方法让您能够使用初始化列表进行赋值。因此，下面的操作都是可能的：
```c++
string name("George Wash");
string pres, veep, source, join, awkward;
pres = name;
weep = "Road Runner";
source = 'X';
join = name + source;     // now with move semantics!
awkward = {'C', 'l', 'o', 'u', 's', 'e', 'a', 'u'};
```

## F.5 字符串搜索
string类提供了6种搜索函数，其中每个函数都有4个原型。下面简要地介绍它们。

### F.5.1 find( )系列
在C++11中，find( )的原型如下：
```c++
size_type find(const basic_string& str, size_type pos = 0) const noexcept;
size_type find(const charT* s, size_type pos = 0) const;
size_type find(const charT* s, size_type pos, size_type n) const;
size_type find(charT c, size_type pos = 0) const noexcept;
```

第一个返回str在调用对象中第一次出现时的起始位置。搜索从pos开始，如果没有找到子字符串，将返回npos。

下面的代码在一个字符串中查找字符串“hat”的位置：
```c++
string longer("That is a funny hat,");
string shorter("hat");
size_type loc1 = longer.find(shorter);            // sets loc1 to 1
size_type loc2 = longer.find(shorter, loc1 + 1);  // sets loc2 to 16
```

由于第二条搜索语句从位置2开始（That中的a），因此它找到的第一个hat位于字符串尾部。要测试是否失败，可使用string::npos值：
```c++
if (loc1 == string::npos)
    cout << "Not found\n";
```

第二个方法完成同样的工作，但它使用字符数组而不是string对象作为子字符串：
```c++
size_type loc3 = longer.find("is");   // sets loc3 to 5
```

第三个方法完成相同的工作，但它只使用字符串s的前n个字符。这与使用basic_string（const charT * s，size_type n）构造函数，然后将得到的对象用作第一种格式的find( )的string参数的效果完全相同。例如，下面的代码搜索子字符串“fun”：
```c++
size_type loc4 = longer.find("funds", 3);   // sets loc4 to 10
```

第四个方法的功能与第一个相同，但它使用一个字符而不是string对象作为子字符串：
```c++
size_type loc5 = longer.find('a');    // sets loc5 to 2
```

### F.5.2 rfind( )系列
rfind( )方法的原型如下：
```c++
size_type rfind(const basic_string& str, size_type pos = npos) const noexcept;
size_type rfind(const charT* s, size_type pos = npos) const;
size_type rfind(const charT* s, size_type pos, size_type n) const;
size_type rfind(charT c, size_type pos = npos) const noexcept;
```

这些方法与相应find( )方法的工作方式相似，但它们搜索字符串最后一次出现的位置，该位置位于pos之前（包括pos）。如果没有找到，该方法将返回npos。

下面的代码从字符串末尾开始查找子字符串“hat”的位置：
```c++
string longer("That is a funny hat.");
string shorter("hat");
size_type loc1 = longer.rfind(shorter);           // sets loc1 to 16
size_type loc2 = longer.rfind(shorter, loc1 - 1); // sets loc2 to 1
```

### F.5.3 find_first_of( )系列
find_first_of( )方法的原型如下：
```c++
size_type find_first_of(const basic_string& str,
                        size_type pos = 0) const noexcept;
size_type find_first_of(const charT* s, size_type pos, size_type n) const;
size_type find_first_of(const charT* s, size_type pos = 0) const;
size_type find_first_of(charT c, size_type pos = 0) const noexcept;
size_type find_first_of(const basic_string& str,
                        size_type pos = 0) const noexcept;
size_type find_first_of(const charT* s, size_type pos, size_type n) const;
size_type find_first_of(const charT* s, size_type pos = 0) const;
size_type find_first_of(charT c, size_type pos = 0) const noexcept;
```

这些方法与对应find( )方法的工作方式相似，但它们不是搜索整个子字符串，而是搜索子字符串中的字符首次出现的位置。
```c++
string longer("That is a funny hat.");
string shorter("fluke");
size_type loc1 = longer.find_first_of(shorter);   // sets loc1 to 10
size_type loc2 = longer.find_first_of("fat");     // sets loc2 to 2
```

在longer中，首次出现的fluke中的字符是funny中的f，而首次出现的fat中的字符是That中的a。

### F.5.4 find_last_of( )系列
find_last_of( )方法的原型如下：
```c++
size_type find_last_of(const basic_string& str,
                      size_type pos = npos) const noexcept;
size_type find_last_of(const charT* s, size_type pos, size_type n) const;
size_type find_last_of(const charT* s, size_type pos = npos) const;
size_type find_last_of(charT c, size_type pos = npos) const noexcept;
```

这些方法与对应rfind( )方法的工作方式相似，但它们不是搜索整个子字符串，而是搜索子字符串中的字符出现的最后位置。

下面的代码在一个字符串中查找字符串“hat”和“any”中字母最后出现的位置：
```c++
string longer("Thar is a funny hat.");
string shorter("hat");
size_type loc1 = longer.find_last_of(shorter);  // sets loc1 to 18
size_type loc2 = longer.find_last_of("any");    // sets loc2 to 17
```

在longer中，最后出现的hat中的字符是hat中的t，而最后出现的any中的字符是hat中的a。

### F.5.5 find_first_not_of( )系列
find_first_not_of( )方法的原型如下：
```c++
size_type find_first_not_of(const basic_string& str,
                      size_type pos = 0) const noexcept;
size_type find_first_not_of(const charT* s, size_type pos, size_type n) const;
size_type find_first_not_of(const charT* s, size_type pos = 0) const;
size_type find_first_not_of(charT c, size_type pos = 0) const noexcept;
```

这些方法与对应find_first_of( )方法的工作方式相似，但它们搜索第一个不位于子字符串中的字符。

下面的代码在字符串中查找第一个没有出现在“This”和“Thatch”中的字母：
```c++
string longer("That is a funny hat.");
string shorter("This");
size_type loc1 = longer.find_first_not_of(shorter);     // sets loc1 to 2
size_type loc2 = longer.find_first_not_of("Thatch");    // sets loc2 to 4
```

在longer中，That中的a是第一个在This中没有出现的字符，而字符串longer中的第一个空格是第一个没有在Thatch中出现的字符。

### F.5.6 find_last_not_of( )系列
find_last_not_of( )方法的原型如下：
```c++
size_type find_last_not_of(const basic_string& str,
                      size_type pos = npos) const noexcept;
size_type find_last_not_of(const charT* s, size_type pos, size_type n) const;
size_type find_last_not_of(const charT* s, size_type pos = npos) const;
size_type find_last_not_of(charT c, size_type pos = npos) const noexcept;
```

这些方法与对应find_last_of( )方法的工作方式相似，但它们搜索的是最后一个没有在子字符串中出现的字符。

下面的代码在字符串中查找最后一个没有出现在“That.”中的字符：
```c++
string longer("That is a funny hat.");
string shorter("That.");
size_type loc1 = longer.find_last_not_of(shorter);        // sets loc1 to 15
size_type loc2 = longer.find_last_not_of(shorter, 10);    // sets loc2 to 10
```

在longer中，最后的空格是最后一个没有出现在shorter中的字符，而longer字符串中的f是搜索到位置10时，最后一个没有出现在shorter中的字符。

## F.6 比较方法和函数
string类提供了用于比较2个字符串的方法和函数。下面是方法的原型：
```c++
int compare(const basic_string& str) const noexcept;
int compare(size_type pos1, size_type n1, const basic_string& str) const;
int compare(size_type pos1, size_type n1, const basic_string& str, size_type pos2, size_type n2) const;
int compare(const charT* s) const;
int compare(size_type pos1, size_type n1, const charT* s) const;
int compare(size_type pos1, size_type n1, const charT* s, size_type n2) const;
```

这些方法使用traits::compare( )方法，后者是为用于字符串的字符类型定义的。如果根据traits::compare( )提供的顺序，第一个字符串位于第二个字符串之前，则第一个方法将返回一个小于0的值；如果这两个字符串相同，则它将返回0；如果第一个字符串位于第二个字符串的后面，则它将返回一个大于0的值。如果较长的字符串的前半部分与较短的字符串相同，则较短的字符串将位于较长的字符串之前。
```c++
string s1("bellflower");
string s2("bell");
string s3("cat");
int a13 = s1.compare(s3);   // a13 is < 0
int a12 = s1.compare(s2);   // a12 is > 0
```

第二个方法与第一个方法相似，但它进行比较时，只使用第一个字符串中从位置pos1开始的n1个字符。

下面的示例将字符串s1的前4个字符同字符串s2进行比较：
```c++
string s1("bellflower");
string s2("bell");
int a2 = s1.compare(0, 4, s2);    // a2 is 0
```

第三个方法与第一个方法相似，但它使用第一个字符串中从pos1位置开始的n1个字符和第二个字符串中从pos2位置开始的n2个字符进行比较。例如，下面的语句将对stout中的out和about中的out进行比较：
```c++
string st1("stout boar");
string st2("mad about ewe");
int a3 = st1.compare(2, 3, st2, 6, 3);    // a3 is 0
```

第四个方法与第一个方法相似，但它将一个字符数组而不是string对象作为第二个字符串。

第五和六个方法与第三个方法相似，但将一个字符串数组而不是string对象作为第二个字符串。

非成员比较函数是重载的关系运算符：
```c++
operator==()
operator<()
operator<=()
operator>()
operator>=()
operator!=()
```

每一个运算符都被重载，使之将string对象与string对象进行比较、将string对象与C-风格字符串进行比较、将C-风格字符串与string对象进行比较。它们都是根据compare( )方法定义的，因此提供了一种在表示方面更为方便的比较方式。

## F.7 字符串修改方法
string类提供了多个用于修改字符串的方法，其中绝大多数都拥有大量的重载版本，因此可用于string对象、字符串数组、单个字符和迭代器区间。

### F.7.1 用于追加和相加的方法
可以使用重载的+ =运算符或append( )方法将一个字符串追加到另一个字符串的后面。如果得到的字符串长于最大字符串长度，将引发length_error异常。+=运算符使得能够将string对象、字符串数组或单个字符追加到string对象的后面：
```c++
basic_string& operator+=(const basic_string& str);
basic_string& operator+=(const charT* s);
basic_string& operator+=(charT c);
```

append( )方法也使得能够将string对象、字符串数组或单个字符追加到string对象的后面。此外，通过指定初始位置和追加的字符数，或者通过指定区间，还可以追加string对象的一部分。通过指定要使用字符串中的多少个字符，可以追加字符串的一部分。追加字符的版本使得能够指定要复制该字符的多少个实例。下面是各种append( )方法的原型：
```c++
basic_string& append(const basic_string& str);
basic_string& append(const basic_string& str, size_type pos, size_type n);
template<class InputIterator>
basic_string& append(InputIterator first, InputIterator last);
basic_string& append(const charT* s);
basic_string& append(const charT* s, size_type n);
basic_string& append(size_type n, charT c);   // append n copies of c
void push_back(charT c);                      // append 1 copy of c
```

下面是几个示例：
```c++
string test("The");
test.append("ory");   // test is "Theory"
test.append(3, '!');  // test is "Theory!!!"
```

operator+( )函数被重载，以便能够拼接字符串。该重载函数不修改字符串，而是创建一个新的字符串，该字符串是通过将第二个字符串追加到第一个字符串后面得到的。加法函数不是成员函数，它们使得能够将string对象和string对象、string对象和字符串数组、字符串数组和string对象、string对象和字符以及字符和string对象相加。下面是一些例子：
```c++
string st1("red");
string st2("rain");
string st3 = st1 + "uce";   // st3 is "reduce"
string st4 = 't' + st2;     // st4 is "train"
string st5 = st1 + st2;     // st5 is "redrain"
```

### F.7.2 其他赋值方法
除了基本的赋值运算符外，string类还提供了assign( )方法，该方法使得能够将整个字符串、字符串的一部分或由相同字符组成的字符序列赋给string对象。下面是各种assign( )方法的原型：
```c++
basic_string& assign(const basic_string& str);
basic_string& assign(basic_string&& str) noexcept;    // C++11
basic_string& assign(const basic_string& str, size_type pos, size_type n);
basic_string& assign(const charT* s, size_type n);
basic_string& assign(const charT* s);
basic_string& assign(size_type n, charT c);   // assign n copies of c
template<class InputIterator>
basic_string& assign(InputIterator first, InputIterator last);
basic_string& assign(initializer_list<charT>);    // C++11
```

下面是几个例子：
```c++
string test;
string stuff("set tubs clones ducks");
test.assign(stuff, 1, 5);   // test is "et tu"
test.assign(6, "#");        // test is "######"
```

接受右值引用作为参数的assign( )方法是C++11新增的，它支持移动语义；另一个新增的assign( )方法让您能够将initializer_list赋给string对象。

### F.7.3 插入方法
insert( )方法使得能够将string对象、字符串数组或几个字符插入到string对象中。这个方法与append( )方法相似，但它还接受另一个指定插入位置的参数，该参数可以是位置，也可以是迭代器。数据将被插入到插入点的前面。有几种方法返回一个指向得到的字符串的引用。如果pos1超过了目标字符串结尾，或者pos2超过了要插入的字符串结尾，该方法将引发out_of_range异常。如果得到的字符串长于最大长度，该方法将引发length_error异常。下面是各种insert( )方法的原型：
```c++
basic_string& insert(size_type pos1, const basic_string& str);
basic_string& insert(size_type pos1, const basic_string& str, size_type pos2, size_type n);
basic_string& insert(size_type pos, const charT* s, size_type n);
basic_string& insert(size_type pos, const charT* s);
basic_string& insert(size_type pos, size_type n, charT c);
iterator insert(const_iterator p, charT c);
iterator insert(const_iterator p, size_type n, charT c);
template<class InputIterator>
void insert(iterator p, InputIterator first, InputIterator last);
iterator insert(const_iterator p, initializer_list<charT>);   // C++11
```

例如，下面的代码将字符串“former”字符串插入到“The banker.”中b的前面：
```c++
string st3("The banker.");
st3.insert(4, "former ");
```

而下面的代码将字符串“ waltzed”（不包括！，它是第9个字符）插入到“The former banker.”末尾的句号之前：
```c++
st3.insert(st3.size() - 1, " waltzed", 8);
```

### F.7.4 清除方法
erase( )方法从字符串中删除字符，其原型如下：
```c++
basic_string& erase(size_type pos = 0, size_type n = npos);
iterator erase(const_iterator position);
iterator erase(const_iterator first, const_iterator last);
void pop_back();
```

第一种格式将从pos位置开始，删除n个字符或删除到字符串尾。第二种格式删除迭代器位置引用的字符，并返回指向下一个元素的迭代器；如果后面没有其他元素，则返回end( )。第三种格式删除区间[first，last）中的字符，即从first（包括）到last（不包括）之间的字符；它返回最后一个迭代器，该迭代器指向最后一个被删除的元素后面的一个元素。最后，方法pop_back( )删除字符串中的最后一个字符。

### F.7.5 替换方法
各种replace( )方法都指定了要替换的字符串部分和用于替换的内容。可以使用初始位置和字符数目或迭代器区间来指定要替换的部分。替换内容可以是string对象、字符串数组，也可以是特定字符的多个实例。对于用于替换的string对象和数组，可以通过指定特定部分（使用位置和计数或只使用计数）或迭代器区间做进一步的修改。下面是各种replace( )方法的原型：
```c++
basic_string& replace(size_type pos1, size_type n1, const basic_string& str);
basic_string& replace(size_type pos1, size_type n1, const basic_string& str, size_type pos2, size_type n2);
basic_string& replace(size_type pos, size_type n1, const charT* s, size_type n2);
basic_string& replace(size_type pos, size_type n1, const charT* s);
basic_string& replace(size_type pos, size_type n1, size_type n2, charT c);
basic_string& replace(const_iterator i1, const_iterator i2, const basic_string& str);
basic_string& replace(const_iterator i1, const_iterator i2, const charT* s, size_tyep n);
basic_string& replace(const_iterator i1, const_iterator i2, const charT* s);
basic_string& replace(const_iterator i1, const_iterator i2, size_type n, charT c);
template<class InputIterator>
basic_string& replace(const_iterator i1, const_iterator i2, InputIterator j1, InputIterator j2);
basic_string& replace(const_iterator i1, const_iterator i2, initializer_list<charT> i1);
```

下面是一个例子：
```c++
string test("Take a right turn at Main Street.");
test.replace(7, 5, "left");   // replace right with left
```

注意，您可以使用find( )来找出要在replace( )中使用的位置：
```c++
string s1 = "old";
string s2 = "mature";
string s3 = "The old man and the sea";
string::size_type pos = s3.find(s1);
if (pos != string::npos)
    s3.replace(pos, s1.size(), s2);
```

上述代码将old替换为mature。

### F.7.6 其他修改方法：copy( )和swap( )
copy( )方法将string对象或其中的一部分复制到指定的字符串数组中：
```c++
size_type copy(charT* s, size_type n, size_type pos = 0) const;
```

其中，s指向目标数组，n是要复制的字符数，pos指出从string对象的什么位置开始复制。复制将一直进行下去，直到复制了n个字符或到达string对象的最后一个字符。函数返回复制的字符数，该方法不追加空值字符，同时由程序员负责检查数组的长度是否足够存储复制的内容。

警告：copy( )方法不追加空值字符，也不检查目标数组的长度是否足够。

swap( )方法使用一个时间恒定的算法来交换两个string对象的内容：
```c++
void swap(basic_string& str);
```

## F.8 输出和输入
string类重载了<<运算符来显示string对象，该运算符返回istream对象的引用，因此可以拼接输出：
```c++
string claim("The string class has many features.");
cout << claim << endl;
```

string类重载了>>运算符，使得能够将输入读入到字符串中：
```c++
string who;
cin >> who;
```

到达文件尾、读取字符串允许的最大字符数或遇到空白字符后，输入将终止（空白的定义取决于字符集以及charT表示的类型）。

有两个getline( )函数，第一个的原型如下：
```c++
template<class charT, class traits, class Allocator>
basic_istream<charT, traits>& getline(basic_istream<charT, traits>& is,
              basic_string<charT, traits, Allocator>& str, charT delim);
```

这个函数将输入流is中的字符读入到字符串str中，直到遇到定界字符delim、到达文件尾或者到达字符串的最大长度。delim字符将被读取（从输入流中删除），但不被存储。第二个版本没有第三个参数，同时使用换行符（或其广义形式），而不是delim：
```c++
string str1, str2;
getline(cin, str1);       // read to end-of-line
getline(cin, str2, '.');  // read to period
```









