CXX = clang++
CXXFLAGS = -Wall -Werror -std=c++20 -Iinclude

SRC = src/kv_store.cpp tests/test.cpp
OBJ = $(SRC:.cpp=.o)

all: kv_store_test

kv_store_test: $(OBJ)
	$(CXX) $(OBJ) -o kv_store_test

# Pattern rule to compile .cpp -> .o
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) kv_store_test

