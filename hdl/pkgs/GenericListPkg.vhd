library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- Based on https://vhdlwhiz.com/string-list/

package GenericListPkg is
    generic (type element_t);
    
    type list is protected
        -- Allows appending to the end of the list
        procedure append(e : element_t);

        -- Allows inserting into a specific element of a list
        procedure insert(i : integer; e : element_t);

        -- Allows grabbing an element at a specific index of a list
        impure function get(i : integer) return element_t;

        -- Allows deleting an element at a specific index of a list
        procedure delete(i : integer);

        -- Empties entire list
        procedure clear;

        -- Gets length of entire list
        impure function length return integer;
    end protected;
    
end package GenericListPkg;

package body GenericListPkg is
    
    type list is protected body
        type element_ptr_t is access element_t;
    
        type node_t;
        type node_ptr_t is access node_t;
        type node_t is record
            element   : element_ptr_t;
            next_node : node_ptr_t;
        end record node_t;
    
        variable root_n   : node_ptr_t;
        variable length_n : integer := 0;
        
        procedure append(e : element_t) is
        begin
            insert(length_n, e);
        end procedure;
    
        procedure insert(i : integer; e : element_t) is
            variable new_node : node_ptr_t;
            variable index    : integer;
            variable node     : node_ptr_t;
        begin
            new_node := new node_t;
            new_node.element := new element_t'(e);
    
            if (i >= length_n) then
                index := length_n;
            elsif (i <= -length_n) then
                index := 0;
            else
                index := i mod length_n;
            end if;
    
            if (index = 0) then
                new_node.next_node := root_n;
                root_n := new_node;
            else
                node := root_n;
                for ii in 2 to index loop
                    node := node.next_node;
                end loop;
    
                new_node.next_node := node.next_node;
                node.next_node := new_node;
            end if;
    
            length_n := length_n + 1;
        end procedure;
    
        impure function get_index(i : integer) return integer is
        begin
            assert i >= -length_n and i < length_n 
                report "GenericListPkg::get_index: index i out of list range" 
                severity failure;
            return i mod length_n;
        end function;
    
        impure function get_node(i : integer) return node_ptr_t is
            variable node : node_ptr_t;
        begin
            node := root_n;
            for ii in 1 to get_index(i) loop
                node := node.next_node;
            end loop;
            return node;
        end function;
    
        impure function get(i : integer) return element_t is
        begin
            return get_node(i).element.all;
        end function;
    
        procedure delete(i : integer) is
            constant cIndex      : integer := get_index(i);
            variable node        : node_ptr_t;
            variable parent_node : node_ptr_t;
        begin
            if (cIndex = 0) then
                node   := root_n;
                root_n := root_n.next_node;
            else
                parent_node           := get_node(cIndex - 1);
                node                  := parent_node.next_node;
                parent_node.next_node := node.next_node;
            end if;
    
            deallocate(node.element);
            deallocate(node);
    
            length_n := length_n - 1;
        end procedure;
    
        procedure clear is
        begin
            while length_n > 0 loop
                delete(0);
                -- length is decremented in delete
            end loop;
        end procedure;
        
        impure function length return integer is
        begin
            return length_n;
        end function;
    end protected body;

end package body GenericListPkg;