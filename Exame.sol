pragma solidity ^0.5.1;

contract Exame{
    struct solicitacaoExame{
        string nomeExame;
        address addressUsuario;
        string dataSolicitada;
        uint custoExameReais;
        uint custoExameTH;
        bool resultado;
        string statusAtual;
        bool pagamentoToken;
    }
    

    address owner;
    solicitacaoExame[] private solicitacoes;
    uint custoExameReaisPagamentoToken;
    uint custoExameReaisPagamentoSemToken;

    uint custoExameTHPagamentoComTokens;
    uint custoBonuficacaoTHPagamentoSemTokens;
    
    TokenHealth contratoTH;

    constructor(uint pagamentoToken,uint pagamentoSemToken, uint custoTH, uint custoBonus, TokenHealth tokenhealth) public {
        custoExameReaisPagamentoToken = pagamentoToken;
        custoExameReaisPagamentoSemToken = pagamentoSemToken;
        custoExameTHPagamentoComTokens = custoTH;
        custoBonuficacaoTHPagamentoSemTokens = custoBonus;
        owner = msg.sender;
        contratoTH = tokenhealth;
    }

    function agendarExame(string memory nomeExame, string memory dataExame, bool pagamentoToken)public returns(uint){        
        if(pagamentoToken){
            contratoTH.transfer(owner, custoExameTHPagamentoComTokens);
            
            solicitacoes.push(solicitacaoExame(nomeExame, msg.sender,dataExame,custoExameReaisPagamentoToken,
                                                            custoExameTHPagamentoComTokens, false,"pendente",true));
        }
        else{
            solicitacoes.push(solicitacaoExame(nomeExame, msg.sender,dataExame,custoExameReaisPagamentoSemToken,
                                                            custoBonuficacaoTHPagamentoSemTokens, false,"pendente",false));
        }
        
        return solicitacoes.length - 1;
    }
    
    function getStatusAgendamento(uint index) public view returns(string memory) { 
        require(msg.sender == solicitacoes[index].addressUsuario || msg.sender == owner);
        return solicitacoes[index].statusAtual;        
    }
    
    function getResultadoAgendamento(uint index) public view returns(bool) {
        require(msg.sender == solicitacoes[index].addressUsuario || msg.sender == owner);
        return solicitacoes[index].resultado;        
    }

    function realizaExame(uint index) public{
        require(msg.sender == owner);
        solicitacoes[index].statusAtual = "Processando";
    }

    function cadastraResultado(uint index, bool res) public{
        require(msg.sender == owner);
        solicitacoes[index].statusAtual = "Finalizado";
        solicitacoes[index].resultado = res;
        
        if(!solicitacoes[index].pagamentoToken){
            contratoTH.transfer(solicitacoes[index].addressUsuario, solicitacoes[index].custoExameTH);
        }

    }

}