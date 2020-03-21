set serveroutput on size 30000;
DECLARE
    -- Credits : Arun Raj / http://www.quest4apps.com/create-xml-using-dbms_xmldom/
    /*
    -- XML formt needed
    <SUPPLIER_DETAILS>
        <SUPPLIER>
            <SUPPLIER_NUMBER> </SUPPLIER_NUMBER>
            <SUPPLIER_NAME> </SUPPLIER_NAME>
        </SUPPLIER>
        <SUPPLIER>
            <SUPPLIER_NUMBER> </SUPPLIER_NUMBER>
            <SUPPLIER_NAME> </SUPPLIER_NAME>
        </SUPPLIER>
    </SUPPLIER_DETAILS>
    
    -- tables needed
    create table test_supplier (supp_number number(10), supp_name varchar2(50))
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
    
    END LOOP;
 
    l_xmltype := dbms_xmldom.getXmlType(l_domdoc);
    dbms_xmldom.freeDocument(l_domdoc);
    
    dbms_output.put_line(l_xmltype.getClobVal);
 
END;