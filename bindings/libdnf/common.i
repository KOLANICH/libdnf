%module common

#define SWIGWORDSIZE64

%include <exception.i>
%include <stdint.i>
%include <std_map.i>
%include <std_pair.i>
%include <std_set.i>
%include <std_string.i>
%include <std_vector.i>

// Cant use %include <catch_error.i> here, SWIG includes each file only once,
// but the exception handler actually doesnt get registered when this file is
// %imported (as opposed to %included).
%exception {
    try {
        $action
    } catch (const std::out_of_range & e) {
        SWIG_exception(SWIG_IndexError, e.what());
    } catch (const std::exception & e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

%template(VectorString) std::vector<std::string>;
%template(SetString) std::set<std::string>;
%template(PairStringString) std::pair<std::string, std::string>;
%template(VectorPairStringString) std::vector<std::pair<std::string, std::string>>;
%template(MapStringString) std::map<std::string, std::string>;
%template(MapStringMapStringString) std::map<std::string, std::map<std::string, std::string>>;
%template(MapStringPairStringString) std::map<std::string, std::pair<std::string, std::string>>;

%define disown_init(ClassName)
#if defined(SWIGPYTHON)
%pythoncode %{
def ClassName##__disown_init__(self, ptr):
    self.__origin_init__(ptr)
    ptr.this.disown()
ClassName.__origin_init__ = ClassName.__init__
ClassName.__init__ = ClassName##__disown_init__
del ClassName##__disown_init__
%}
#endif
%enddef

namespace std {
  %feature("novaluewrapper") unique_ptr;
  template <typename Type>
  struct unique_ptr {

     explicit unique_ptr(Type * Ptr);
     unique_ptr(unique_ptr && Right);
     template<class Type2, Class Del2> unique_ptr(unique_ptr<Type2, Del2> && Right);
     unique_ptr( const unique_ptr& Right) = delete;

     Type * operator->() const;
     Type * release();
     void reset(Type * __p = nullptr);
     void swap(unique_ptr &__u);
     Type * get() const;
     operator bool() const;

     ~unique_ptr();
  };
}

%define wrap_unique_ptr(Name, Type)
  %template(Name) std::unique_ptr<Type>;
  %newobject std::unique_ptr<Type>::release;

  %typemap(out) std::unique_ptr<Type> %{
    $result = SWIG_NewPointerObj(new $1_ltype(std::move($1)), $&1_descriptor, SWIG_POINTER_OWN);
  %}

  disown_init(Name)
%enddef

#if defined(SWIGPYTHON)
%pythoncode %{
class Iterator:
    def __init__(self, begin, end):
        self.cur = begin
        self.end = end

    def __iter__(self):
        return self

    def __next__(self):
        if self.cur == self.end:
            raise StopIteration
        else:
            value = self.cur.value()
            self.cur.next()
            return value
%}
#endif

%define add_iterator(ClassName)
#if defined(SWIGPYTHON)
%pythoncode %{
def ClassName##__iter__(self):
    return libdnf.common.Iterator(self.begin(), self.end())
ClassName.__iter__ = ClassName##__iter__
del ClassName##__iter__
%}
#endif
%enddef


%{
    #include "libdnf/utils/set.hpp"
    #include "libdnf/utils/weak_ptr.hpp"
    #include "libdnf/common/sack/query.hpp"
    #include "libdnf/common/sack/query_cmp.hpp"
    #include "libdnf/common/sack/sack.hpp"
    #include "libdnf/common/sack/match_int64.hpp"
    #include "libdnf/common/sack/match_string.hpp"
%}

%ignore libdnf::Set::Set;
%include "libdnf/utils/set.hpp"
%include "libdnf/utils/weak_ptr.hpp"
%ignore libdnf::sack::operator|(QueryCmp lhs, QueryCmp rhs);
%ignore libdnf::sack::operator&(QueryCmp lhs, QueryCmp rhs);
%include "libdnf/common/sack/query_cmp.hpp"
%include "libdnf/common/sack/query.hpp"
%include "libdnf/common/sack/sack.hpp"
%include "libdnf/common/sack/match_int64.hpp"
%include "libdnf/common/sack/match_string.hpp"

%{
    #include "libdnf/utils/preserve_order_map.hpp"
%}

%ignore libdnf::PreserveOrderMap::MyBidirIterator;
%ignore libdnf::PreserveOrderMap::MyBidirIterator::operator++;
%ignore libdnf::PreserveOrderMap::MyBidirIterator::operator--;
%ignore libdnf::PreserveOrderMap::begin;
%ignore libdnf::PreserveOrderMap::end;
%ignore libdnf::PreserveOrderMap::cbegin;
%ignore libdnf::PreserveOrderMap::cend;
%ignore libdnf::PreserveOrderMap::rbegin;
%ignore libdnf::PreserveOrderMap::rend;
%ignore libdnf::PreserveOrderMap::crbegin;
%ignore libdnf::PreserveOrderMap::crend;
%ignore libdnf::PreserveOrderMap::insert;
%ignore libdnf::PreserveOrderMap::erase(const_iterator pos);
%ignore libdnf::PreserveOrderMap::erase(const_iterator first, const_iterator last);
%ignore libdnf::PreserveOrderMap::count;
%ignore libdnf::PreserveOrderMap::find;
%ignore libdnf::PreserveOrderMap::operator[];
%ignore libdnf::PreserveOrderMap::at;
%include "libdnf/utils/preserve_order_map.hpp"

#if defined(SWIGPYTHON)
%define EXTEND_TEMPLATE_PreserveOrderMap(ReturnT, Key, T...)
    %extend libdnf::PreserveOrderMap<Key, T> {
        ReturnT __getitem__(const Key & key)
        {
            return $self->at(key);
        }

        void __setitem__(const Key & key, const T & value)
        {
            $self->operator[](key) = value;
        }

        void __delitem__(const Key & key)
        {
            if ($self->erase(key) == 0)
                throw std::out_of_range("PreserveOrderMap::__delitem__");
        }

        bool __contains__(const Key & key) const
        {
            return $self->count(key) > 0;
        }

        size_t __len__() const
        {
            return $self->size();
        }
    }
%enddef
EXTEND_TEMPLATE_PreserveOrderMap(T, std::string, std::string)
EXTEND_TEMPLATE_PreserveOrderMap(T &, std::string, libdnf::PreserveOrderMap<std::string, std::string>)
#endif

%template(PreserveOrderMapStringString) libdnf::PreserveOrderMap<std::string, std::string>;
%template(PreserveOrderMapStringPreserveOrderMapStringString) libdnf::PreserveOrderMap<std::string, libdnf::PreserveOrderMap<std::string, std::string>>;

%exception;  // beware this resets all exception handlers if you import this file after defining any
