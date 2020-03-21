set serveroutput on size 30000;
DECLARE
    -- Credits : Arun Raj / http://www.quest4apps.com/create-xml-using-dbms_xmldom/
    /*
    -- XML formt needed
    <SUPPLIER_ADDRESS>
      <SUPPLIER>
        <SUPPLIER_NUMBER> </SUPPLIER_NUMBER>
        <SUPPLIER_NAME> </SUPPLIER_NAME>
        <ADDRESS>
          <ADDRESS1> </ADDRESS1>
          <CITY> </CITY>
        </ADDRESS>
      </SUPPLIER>
    </SUPPLIER_ADDRESS>
    
    -- tables needed
    create table test_supplier (supp_number number(10), supp_name varchar2(50))
    create table test_supplier_dtl (supp_number number(10), supp_address varchar2(100), supp_city varchar2(50))
    */
    
    l_xmltype   XMLTYPE;
    l_domdoc    dbms_xmldom.DOMDocument;
    l_root_node dbms_xmldom.DOMNode;
    
    -- for Supplier element (this is going to repeat for many)
    l_supplier_element    dbms_xmldom.DOMElement;
    l_supplier_node       dbms_xmldom.DOMNode;
    l_sup_node            dbms_xmldom.DOMNode;
    l_sup_element         dbms_xmldom.DOMElement;

    -- for Supplier Number sub-element
    l_supp_num_element    dbms_xmldom.DOMElement;
    l_supp_num_node       dbms_xmldom.DOMNode;
    l_supp_num_tnode      dbms_xmldom.DOMNode;
    l_supp_num_text       dbms_xmldom.DOMText;
    
    -- for Supplier Name sub-element
    l_supp_name_element   dbms_xmldom.DOMElement;
    l_supp_name_node      dbms_xmldom.DOMNode;
    l_supp_name_tnode     dbms_xmldom.DOMNode;
    l_supp_name_text      dbms_xmldom.DOMText;

    -- for Address Details sub-element
    l_addr_dtl_element    dbms_xmldom.DOMElement;
    l_addr_dtl_node       dbms_xmldom.DOMNode;
    
    -- for Supplier Address sub-element
    l_supp_addr_element   dbms_xmldom.DOMElement;
    l_supp_addr_node      dbms_xmldom.DOMNode;
    l_supp_addr_tnode     dbms_xmldom.DOMNode;
    l_supp_addr_text      dbms_xmldom.DOMText;
    
    -- for Supplier City sub-element
    l_supp_city_element   dbms_xmldom.DOMElement;
    l_supp_city_node      dbms_xmldom.DOMNode;
    l_supp_city_tnode     dbms_xmldom.DOMNode;
    l_supp_city_text      dbms_xmldom.DOMText;
       
BEGIN 
    -- Create an empty XML document
    l_domdoc := dbms_xmldom.newDomDocument;
    
    -- Create a root node
    l_root_node := dbms_xmldom.makeNode(l_domdoc);
    
    -- Create a new SUPPLIER_DETAILS (as the parent) Node and add it to the root node
    l_sup_node := dbms_xmldom.appendChild( l_root_node, dbms_xmldom.makeNode(dbms_xmldom.createElement(l_domdoc, 'SUPPLIER_DETAILS')) );
 
    FOR sup_rec IN (SELECT  supp_number, supp_name FROM test_supplier ORDER BY 1)
    LOOP
        -- For each record, create a new Supplier element and add this to the SUPPLIER_DETAILS Parent node
        l_supplier_element := dbms_xmldom.createElement(l_domdoc, 'SUPPLIER' );
        l_supplier_node    := dbms_xmldom.appendChild(l_sup_node,dbms_xmldom.makeNode(l_supplier_element));
        
        -- Each Supplier node will get a Number node which contains the Supplier Number as text
        l_supp_num_element := dbms_xmldom.createElement(l_domdoc, 'SUPPLIER_NUMBER' );
        l_supp_num_node    := dbms_xmldom.appendChild(l_supplier_node,dbms_xmldom.makeNode(l_supp_num_element));
        l_supp_num_text    := dbms_xmldom.createTextNode(l_domdoc, sup_rec.supp_number );
        l_supp_num_tnode   := dbms_xmldom.appendChild(l_supp_num_node,dbms_xmldom.makeNode(l_supp_num_text));
        
        -- Each Supplier node will get a Name node which contains the Supplier Name as text
        l_supp_name_element := dbms_xmldom.createElement(l_domdoc, 'SUPPLIER_NAME' );
        l_supp_name_node    := dbms_xmldom.appendChild(l_supplier_node,dbms_xmldom.makeNode(l_supp_name_element));
        l_supp_name_text    := dbms_xmldom.createTextNode(l_domdoc, sup_rec.supp_name );
        l_supp_name_tnode   := dbms_xmldom.appendChild(l_supp_name_node,dbms_xmldom.makeNode(l_supp_name_text));
    
        FOR add_rec IN (SELECT  supp_address, supp_city FROM test_supplier_dtl WHERE supp_number = sup_rec.supp_number ORDER BY 1)
        LOOP
            -- For each record, create a new Detail element and add this to the SUPPLIER_DETAILS Parent node and add multiple address details
            l_addr_dtl_element := dbms_xmldom.createElement(l_domdoc, 'ADDRESS_DETAILS' );
            l_addr_dtl_node    := dbms_xmldom.appendChild(l_supplier_node,dbms_xmldom.makeNode(l_addr_dtl_element));  

            -- Each Address Details node will get an Address node which contains the Address as text
            l_supp_addr_element := dbms_xmldom.createElement(l_domdoc, 'ADDRESS' );
            l_supp_addr_node    := dbms_xmldom.appendChild(l_addr_dtl_node,dbms_xmldom.makeNode(l_supp_addr_element));
            l_supp_addr_text    := dbms_xmldom.createTextNode(l_domdoc, add_rec.supp_address );
            l_supp_addr_tnode   := dbms_xmldom.appendChild(l_supp_addr_node,dbms_xmldom.makeNode(l_supp_addr_text));

            -- Each Address Details node will get a City node which contains the City as text
            l_supp_city_element := dbms_xmldom.createElement(l_domdoc, 'CITY' );
            l_supp_city_node    := dbms_xmldom.appendChild(l_addr_dtl_node,dbms_xmldom.makeNode(l_supp_city_element));
            l_supp_city_text    := dbms_xmldom.createTextNode(l_domdoc, add_rec.supp_city );
            l_supp_city_tnode   := dbms_xmldom.appendChild(l_supp_city_node,dbms_xmldom.makeNode(l_supp_city_text));

        END LOOP;
    
    END LOOP;
 
    l_xmltype := dbms_xmldom.getXmlType(l_domdoc);
    dbms_xmldom.freeDocument(l_domdoc);
    
    dbms_output.put_line(l_xmltype.getClobVal);
 
END;